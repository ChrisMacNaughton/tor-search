require "#{Rails.root}/lib/robotstxt"
require "#{Rails.root}/lib/tor"
require 'base64'
class Parser
  def initialize(page_id)
    @page_id = page_id
  end
  def log(page, action, reason, type = self.type)
    CrawlerLogEntry.create(page: page, type_str: type, action: action, reason: reason.to_s[0...254])
  end
  def clean(str)
    r = str.force_encoding('ASCII-8BIT').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
    r
  end
end
class PageCrawler < Parser
  def type
    "crawler"
  end
  def execute
    Rails.logger.info "Starting crawler"
    Rails.logger.warn "A page on the domain #{@page.domain.id} almost got through" and return if @page.domain.blocked
    @domain = @page.domain
    delay = @domain.last_crawled.to_i + @domain.crawl_delay
    if delay > DateTime.now.to_i
      Rails.logger.info "Not crawling yet, crawling again after #{delay} seconds"
      requeue(@page_id, @domain.crawl_delay) && return
    end
    unless ['onion/','html','php','htm', 'do'].include? @page.url.split(/\?|#/)[0].split('.')[-1]
      log(@page, 'no_crawl', "bad extension")
      Rails.logger.info "Not crawling #{@page.url} because of a bad extension"
      @page.update_attribute(:no_crawl, true) and return
    end
    begin
      unless Robotstxt.allowed?(@page.url, TorSearch::Application.config.user_agent, @page.domain)
        log(@page, 'skip', "Robots Disallow")
      end
      ago = DateTime.now.to_i - @page.domain.last_crawled.to_i
      delay = Robotstxt.crawl_delay(TorSearch::Application.config.user_agent, @page.domain)
      if !@page.domain.last_crawled.nil? && (ago) < delay
        Rails.logger.info "Not crawling yet, crawling again after #{delay - ago} seconds"
        requeue(@page_id) && return
      end

      Rails.logger.info "Crawling #{@page.url}!"
      log(@page, 'crawling', '')
      attributes = Tor.new.get(@page.url)
    rescue => e
      Rails.logger.warn e.message
      str = e.message
      log(@page, 'error', e)
      # Catch the SOCKS failures
      if str.include? "general SOCKS server failure"
        Rails.logger.debug "Caught first"
        @domain.last_crawled = DateTime.now
        @domain.missed_attempts = 3
        @domain.save
        requeue(@page_id, @page.domain.crawl_delay) and return nil
      elsif str.include? "Host unreachable"
        Rails.logger.debug "Caught second"
        @domain.last_crawled = DateTime.now
        @domain.missed_attempts += 1
        @domain.save
        requeue(@page_id, @page.domain.crawl_delay) and return nil
      elsif str.include? "Redirect limit of 20 reached"
        Rails.logger.debug "Caught third"
        @domain.last_crawled = DateTime.now
        @domain.missed_attempts += 1
        @domain.save
        requeue(@page_id, @page.domain.crawl_delay) and return nil
      elsif str.include? 'connection not allowed by ruleset'
        Rails.logger.debug "Blocking an invalid domain"
        @domain.blocked = true
        @domain.save
      elsif str.include? 'TTL expired'
        Rails.logger.debug "Caught third"
        @domain.last_crawled = DateTime.now
        @domain.missed_attempts += 1
        @domain.save
        requeue(@page_id, @page.domain.crawl_delay) and return nil
      else
        raise
      end
    end

    @domain.missed_attempts = 0
    @domain.last_crawled = DateTime.now
    @domain.save
    if attributes.nil?
      log(@page, 'no_save', "no attributes") and return
    end
    @page.body = clean(attributes.body)
    @page.last_crawled = DateTime.now
    @page.save
  end
  def perform
    @page = Page.where(id: @page_id).first
    Rails.logger.info "Page with id (#{@page_id}) not found" and return if @page.nil?

    execute

    @page.parse
  end
  def requeue(id, delay=300)

    handler      = PageCrawler.new(@page_id)
    handler_hash = Digest::MD5.hexdigest(handler.to_yaml)

    Delayed::Job.enqueue(handler, queue: 'crawl', run_at: DateTime.now + delay.seconds) \
      if Delayed::Job.where(handler: handler_hash).empty?
  end

end

class PageParser < Parser
  def type
    "parser"
  end
  def perform
    execute
  end
  def execute
    begin
      Rails.logger.info "Starting Parser"
      @page = Page.where(id: @page_id).first

      Rails.logger.warn "Page with id (#{@page_id}) not found" and return if @page.nil?

      if @page.domain.blocked
        Rails.logger.info "Not parsing due to blocked domain" and return
      end
      raw = @page.body
      if raw.nil?
        log(@page, 'skipping', 'raw content missing')
        Rails.logger.warn "Raw content for (#{@page_id}) not found" and return
      end
      log(@page, 'parsing', '')
      attributes = Nokogiri::parse(raw)
      if attributes.search('body').first.nil?
        attributes = Nokogiri::parse(Base64.decode64(raw))
        if attributes.search('body').first.nil?
          return
        else
          @page.body = Base64.decode64(raw)
        end
      end
      meta = attributes.search('meta')

      meta_tags = ['description', 'generator', 'keywords']
      meta_content = {}
      Rails.logger.info("Getting meta tags")
      meta_tags.each do |key|
        tag = meta.select { |a|
          a.attributes['name'].value == key unless a.attributes['name'].nil?
        }.first
        meta_content[key] = tag.attributes['content'].value unless tag.nil?
      end

      title = attributes.search('title').first
      if attributes.search('title').first.nil?
        title = ""
      else
        title = title.content
      end
      description = meta_content['description'] || ""
      description = clean(attributes.search('body').children.to_a.join(' ')).gsub(/\s+/, ' ')[0...255] if description.length < 25
      description ||= ""
      keywords = meta_content['keywords'] || ''
      generator = meta_content['generator'] || ''
      Rails.logger.info "About to update page attributes"

      Rails.logger.debug "changing title from '#{@page.title}' to '#{title[0..80]}'"
      @page.title= title[0..80]
      Rails.logger.debug "changing description from '#{@page.description}' to '#{description[0...255]}'"
      @page.description = description
      Rails.logger.debug "changing meta keywords from '#{@page.meta_keywords}' to '#{keywords}'"
      @page.meta_keywords = keywords
      Rails.logger.debug "changing meta generator from '#{@page.meta_generator}' to '#{generator}'"
      @page.meta_generator = generator

      @page.save

      handler      = PageLinker.new(@page_id)
      handler_hash = Digest::MD5.hexdigest(handler.to_yaml)

      Delayed::Job.enqueue(handler, queue: 'links') if Delayed::Job.where(handler: handler_hash).empty?

      handler      = ImageParser.new(@page_id)
      handler_hash = Digest::MD5.hexdigest(handler.to_yaml)

      Delayed::Job.enqueue(handler, queue: 'images') if Delayed::Job.where(handler: handler_hash).empty?

    rescue => e
      log(@page, 'error', e)
      raise
    end
  end
end

class PageLinker < Parser
  def type
    "linker"
  end
  def execute
    begin
      Rails.logger.info "Starting Parser"
      @page = Page.where(id: @page_id).first

      Rails.logger.warn "Page with id (#{@page_id}) not found" and return if @page.nil?

      if @page.domain.blocked
        Rails.logger.info "Not parsing due to blocked domain" and return
      end
      raw = @page.body
      if raw.nil?
        log(@page, 'skipping', 'raw content missing')
        Rails.logger.warn "Raw content for (#{@page_id}) not found" and return
      end
      log(@page, 'parsing', '')
      attributes = Nokogiri::parse(raw)
      #debugger
      Rails.logger.info("getting links")
      @links = attributes.search('a')

      @links.each do |link|
        Rails.logger.debug("Skipping #{link.inspect} because href is nil") and next if link.attributes['href'].nil?
        href = link.attributes['href'].value.gsub(/https?:\/\//, '')
        Rails.logger.debug("Skipping #{link.inspect} because href is a bad format") and next if href =~ /:\/\//
        matches = href.match(/(.*\.onion)/i)
        next unless ['onion/','html','php','htm', 'do'].include? @page.url.split(/\?|#/)[0].split('.')[-1]
        next unless link.attributes['href'].value.match(/https?:\/\//).nil?

        root_path = if matches.nil?
          @page.domain.path
        else
          matches[0]
        end
        path = href.gsub(root_path, '')

        next if root_path.nil?
        anchor = link.children.to_s
        Rails.logger.info("finding domain")
        domain = Domain.where(path: root_path).first
        if domain.nil?
          Rails.logger.info("didn't exist! making a new domain!")
          domain = Domain.create(path: root_path)
          domain.crawl!
        end
        format = @page.url.split(/\?|#/)[0].split('.')[-1]

        if ['onion/','html','php','htm', 'do'].include? format
          Rails.logger.info("finding page")
          target = Page.where(domain_id: domain.id, path: path.split("#")[0]).first
          if target.nil?
            Rails.logger.info("didn't exist! making a new page!")
            target = Page.create(domain: domain, path: path)
            target.crawl
          end
        elsif ['jpg','png','gif'].include? format
          #images
          target = Image.create!(path: path, domain: domain)
        elsif ['txt','pdf'].include? format
          #document
          target = Document.create!(path: path, domain: domain)
        end
        l = Link.where(from_target_id: @page.id, from_target_type: @page.class.to_s, to_target_id: target.id, to_target_type: target.class.to_s ).first
        if l.nil?
          Rails.logger.info("Found a new link!")
          l = Link.create(from_target: @page, to_target: target, anchor_text: clean(anchor))
        end
      end
    rescue => e
      log(@page, 'error', e)
      raise
    end
  end
  def perform
    execute
  end
end

class ImageParser < Parser
  def type
    "image_parser"
  end
  def execute
    begin
      @page = Page.where(id: @page_id).first

      Rails.logger.warn "Page with id (#{@page_id}) not found" and return if @page.nil?

      if @page.domain.blocked
        Rails.logger.info "Not parsing due to blocked domain" and return
      end
      raw = @page.body
      if raw.nil?
        log(@page, 'skipping', 'raw content missing')
        Rails.logger.warn "Raw content for (#{@page_id}) not found" and return
      end
      log(@page, 'parsing', '')
      attributes = Nokogiri::parse(raw)
      #debugger
      Rails.logger.info("getting links")
      @images = attributes.search('img')

      @images.each do |link|
        Rails.logger.debug("Skipping #{link.inspect} because href is nil") and next if link.attributes['src'].nil?
        href = link.attributes['src'].value.gsub(/https?:\/\//, '')
        Rails.logger.debug("Skipping #{link.inspect} because href is a bad format") and next if href =~ /:\/\//

        matches = href.match(/(.*\.onion)/i)
        next unless ['jpg','gif','png'].include? href.split(/\?|#/)[0].split('.')[-1]
        next unless link.attributes['src'].value.match(/https?:\/\//).nil?

        root_path = if matches.nil?
          @page.domain.path
        else
          matches[0]
        end
        path = href.gsub(root_path, '')

        next if root_path.nil?
        anchor = link.children.to_s
        Rails.logger.info("finding domain")
        domain = Domain.where(path: root_path).first
        if domain.nil?
          Rails.logger.info("didn't exist! making a new domain!")
          domain = Domain.create(path: root_path)
          domain.crawl!
        end

        target = Image.where(domain_id: domain.id, path: path.split("#")[0]).first
        if target.nil?
          Rails.logger.info("didn't exist! making a new image!")
          alt_text = if link.attributes['alt']
            link.attributes['alt'].value
          else
            ""
          end
          target = Image.create!(path: path, domain: domain, alt_text: alt_text)
        end
      end
    rescue => e
      log(@page, 'error', e)
      raise
    end
  end
  def perform
    execute
  end
end

class Thumbnailer < Parser
  def type
    "thumbnailer"
  end
  def initialize(image_id)
    @image_id = image_id
  end
  def execute
    path = Tor.new.get_image(@image.url)
    return if path.nil?
    File.open(path) { |i| @image.image = i }
    @image.save
  end
  def perform
    @image = Image.where(id: @image_id).first
    Rails.logger.warn "Image with id (#{@image_id}) not found" and return if @image.nil?

    @domain = @image.domain
    delay = @domain.last_crawled.to_i + @domain.crawl_delay
    if delay > DateTime.now.to_i
      Rails.logger.info "Not crawling yet, crawling again after #{delay} seconds"
      requeue(@image_id, @domain.crawl_delay) && return
    end
    begin
      unless Robotstxt.allowed?(@image.url, TorSearch::Application.config.user_agent, @image.domain)
        log(@image, 'skip', "Robots Disallow")
      end
      ago = DateTime.now.to_i - @image.domain.last_crawled.to_i
      delay = Robotstxt.crawl_delay(TorSearch::Application.config.user_agent, @image.domain)
      if !@image.domain.last_crawled.nil? && (ago) < delay
        Rails.logger.info "Not crawling yet, crawling again after #{delay - ago} seconds"
        requeue(@image_id) && return
      end

      execute
    rescue => e
      log(@page, 'error', e)
      raise
    end
  end
  def requeue(id, delay=300)

    handler      = PageCrawler.new(@page_id)
    handler_hash = Digest::MD5.hexdigest(handler.to_yaml)

    Delayed::Job.enqueue(handler, queue: 'crawl', run_at: DateTime.now + delay.seconds) \
      if Delayed::Job.where(handler: handler_hash).empty?
  end
end