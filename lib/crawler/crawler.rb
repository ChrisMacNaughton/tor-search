require "#{Rails.root}/lib/robotstxt"
require "#{Rails.root}/lib/tor"

class Crawler
  def initialize (url)
    @url = url.gsub(/^https?:\/\//, '')
  end
  def execute
    @target ||= get_target
    return unless good_to_crawl

    @tor = Tor.new

    head = tor_method('head')
    return if head == false

    unless head.is_a? Mechanize::Page
      Rails.logger.info "Page isn't a page, it's a #{head.class.to_s} bailing"

      if head.nil?
        @target.update_attribute(:no_crawl, true)
      end
      return
    end

    result = tor_method
    if result.nil?
      Rails.logger.info "Page is nil, bailing"
      return
    end
    domain.missed_attempts = 0
    domain.save
    domain.reload
    if result.is_a? Mechanize::Page

      page = build_page_attributes(result)

      #roll through all of the images on the page
#      result.images.each do |i|
#        path = i.url.path
#        hostname = i.url.hostname
#
#        alt = i.alt
#        i = nil
#
#        d = Domain.where(path: hostname).first
#        if d.nil?
#          d = Domain.create!(path: hostname)
#        end
#        i = Image.where(path: path, domain_id: d.id).first
#        if i.nil?
#          i = Image.create!(path: path, domain_id: d.id)
#        end
#
#        i.alt_text = alt
#        i.save
#
#        requeue(i.url)
#      end

      #roll through all of the links on the page
      checked = []
      result.links.each do |l|
        next if l.href.nil?
        if checked.include? l.href
          Rails.logger.debug "Already checked #{l.href}"
          next
        end
        Rails.logger.debug("Got a link: #{l.href}")
        checked << l.href
        href = l.href.gsub(/^http:\/\//, '')
        anchor_text = l.text

        d = l.uri.hostname
        if d.nil?
          d = domain.path
        end


        link_path = path_splitter(href.gsub(d, ''))

        link_path = if link_path.nil?
          ''
        else
          link_path.gsub(/^\.?/, '').gsub(/^\//, '')
        end
        next if link_path.nil?

        next if d == false

        unless Domain.valid_path?(d)
          Rails.logger.debug("skipping #{d} because it's invalid")
          next
        end

        Rails.logger.debug("Using domain_name #{d} with path #{link_path}")
        link_domain = Domain.where(path: d).first
        if link_domain.nil?
          link_domain = Domain.create!(path: d)
        end


        target = Page.where(path: link_path, domain_id: link_domain.id).first

        if target.nil?
          #we need to find out what it is
          t = tor_method('head', "http://" + ("#{d}/#{href}".gsub(/\/{2,}}/,'/')))
          if t.is_a? Mechanize::Page
            target = Page.where(path: link_path, domain_id: link_domain.id).first
            if target.nil?
              target = Page.create!(path: link_path, domain_id: link_domain.id)
            end
          else
            next
          end
        end
        next if target.nil?
        link = Link.where(from_target_id: page.id, to_target_id: target.id).first
        if link.nil?
          Link.create!(from_target_id: page.id, to_target_id: target.id, anchor_text: anchor_text)
        end
      end

    elsif result.is_a? Mechanize::Image
      image = build_image_attributes(result)
    else

    end
  end

  def domain_path
    if @domain_path.nil?
      root = @url.split('.')[0]

      if root.length > 16
        root = root[-16..-1]
      end

      valid = (root.length == 16)
      if valid
        @domain_path = "#{root}.onion"
      else
        Rails.logger.warn("Invalid domain detected: #{@url.split('.')[0]}")
        raise "Invalid Domain"
      end
    end
    @domain_path
  end
  def url_path
    @path ||= path_splitter(@url.gsub(domain.path, '').gsub(/^\//, '')) || ""
  end
  def perform
    execute
  end
  private
  def url_splitter(url)
    match = url.match(/(.*\.#{tld.join('|')})/i)
    if match.nil?
      ""
    else
      match[0].split('/')
    end
  end
  def path_splitter(path)
    path.split(/#/)[0]
  end
  def get_domain(url)
    d = url_parts(url)[0]
    if d.nil?
      return domain
    end
    if valid_domain(d)
      return d
    end
    initial = d.split('.onion')[0]
    if valid_domain(initial[-16..-1])
      return "#{initial[-16..-1]}.onion"
    end
    false
  end
  def get_path(url)
    path_splitter(url_parts(url)[1])
  end
  def url_parts(url)
    url.gsub(/^https?:\/\//, '').split('/', 1)
  end
  def tld
    ['onion']
  end
  def valid_domain(url)
    d = url.split('.onion')
    return false if d.nil?
    return true if d[0].length == 16
    false
  end
  def domain
    @domain ||= Domain.where(path: domain_path).first

    @domain ||= Domain.create(path: domain_path)

    @domain
  end
  def get_target
    @t ||= Page.where(path: url_path, domain_id: domain.id).first
  end
  def parse(text, look_for = ['title','body','description','meta_generator','meta_keywords'])
    values = {}
    look_for.each do |k|
      values[k] = ""
      case values
      when 'title'
        values[k] = text.title.to_s[0...80]
      when 'description'
        @body ||= clean(res.search('body').children.to_a.join(' ')).gsub(/\s+/, ' ')
        @body[0...255]
      when 'body'
        @body ||= clean(res.search('body').children.to_a.join(' ')).gsub(/\s+/, ' ')
        @body
      when 'meta_generator'
        @meta = clean(text.search('meta'))
        @meta.select{|v| !v.attributes['name'].nil? && v.attributes["name"].value.downcase == 'generator'}
      when 'meta_keywords'
        @meta = clean(text.search('meta'))
        @meta.select{|v| !v.attributes['name'].nil? && v.attributes["name"].value.downcase == 'keywords'}
      end
    end
    values
  end
  def tor_method(method = 'get', address = @url)
    Rails.logger.debug ("visiting #{address} with method #{method}")
    unless address =~ /https?:\/\//
      address = "http://#{address}"
    end
    begin
      res = @tor.proxy_mechanize do
        agent = Mechanize.new
        agent.user_agent = TorSearch::Application.config.user_agent
        begin
          agent.send( method, address.gsub(' ', '%20'))
        rescue Mechanize::ResponseCodeError
        end
      end

    rescue => e
      str = e.message
      if rescue_block(str)
        return true
      else
        raise
      end
    end
    res
  end
  def build_page_attributes(mech)
    t = Page.where(path: url_path, domain_id: domain.id).first
    if t.nil?
      t = Page.create!(path: url_path, domain_id: domain.id)
    end

    meta = mech.search('meta')

    keywords = meta.select{|v| !v.attributes['name'].nil? && v.attributes["name"].value.downcase == 'keywords'}[0]
    unless keywords.nil? or (keywords.is_a?(Array) and ( keywords[0].nil? or keywords[0].attributes['content'].nil?))
      if keywords.is_a? Array
        keywords = keywords[0]
      end
      keywords = keywords.attributes['content'].value
    end
    keywords = "" if keywords.nil?
    keywords = keywords.flatten.join(' ') if keywords.is_a? Array
    generator = meta.select{|v| !v.attributes['name'].nil? && v.attributes["name"].value.downcase == 'generator'}
    unless generator.nil? or (generator.is_a?(Array) and ( generator[0].nil? or generator[0].attributes['content'].nil?))
      generator = generator[0].attributes['content'].value
    end
    body = mech.search('body').children.to_a.flatten.join(' ')

    generator = "" if generator.nil?
    generator = generator.flatten.join(' ') if generator.is_a? Array
    t.title = clean(mech.title || "")[0..80]
    t.body = clean(body).gsub(/\s+/, ' ')
    t.meta_keywords = clean(keywords)
    t.meta_generator = clean(generator)
    t.description = clean(body).gsub(/\s+/, ' ')[0..255]
    t.last_crawled = DateTime.now
    t.save
    t.reload
    Rails.logger.debug("Built the page ##{t.id}")
    t
  end
  def build_image_attributes(mech)
    i = Image.where(path: url_path, domain_id: domain.id).first
    if i.nil?
      i = Image.create!(path: url_path, domain_id: domain.id)
    end
    return false if i.disabled
    i.last_crawled = DateTime.now
    filename = mech.filename
    name_parts = filename.split('.')
    name_parts.pop if name_parts.length > 1
    extension = mech.response['content-type'].split("/")[-1]
    filename = "tmp/images/#{ name_parts.join('.')}.img#{i.id}.#{extension}"
    mech.save!("#{filename}")

    File.open(filename) { |image| i.image = image }
    i.reload
    File.unlink(filename)
    i
  end
  def clean(str)
    return if str.nil?
    r = str.force_encoding('ASCII-8BIT').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
    r
  end
  def good_to_crawl
    if domain.blocked?
      Rails.logger.debug("Skipping #{@url} because domain is blocked")
      return false
    end
    unless @target.nil?
      crawled = 1.year.ago
      if @target.is_a? Page
        if @target.no_crawl
          Rails.logger.debug("Skipping #{@url} because page is no-crawled")
          return false
        end
      end
      crawled = @target.last_crawled || 1.year.ago
      if DateTime.now < crawled + TorSearch::Application.config.tor_search.page_interval
        Rails.logger.debug("Skipping #{@url} because it has been crawed too recently")
        requeue(@url,crawled + TorSearch::Application.config.tor_search.page_interval)
        return false
      end
    end
    begin
      unless Robotstxt.allowed?(@url, TorSearch::Application.config.user_agent, @domain)
        Rails.logger.debug("Skipping #{@url} because robots.txt disallows it")
        @target.no_crawl = true
        @target.save
        return false
      end
      ago = DateTime.now.to_i - @domain.last_crawled.to_i
      delay = Robotstxt.crawl_delay(TorSearch::Application.config.user_agent, @domain)
      if !@domain.last_crawled.nil? && (ago) < delay
        Rails.logger.debug("Skipping #{@url} because domain was crawled too recently")
        requeue(@target.path) and return false
      end
    rescue => e
      str = e.message
      if rescue_block(str)
        return false
      else
        raise
      end
    end
    return true if domain.last_crawled.nil?
    return true if domain.last_crawled < TorSearch::Application.config.tor_search.update_interval.ago

    false
  end
  def requeue(url, delay=300.seconds)

    handler      = Crawler.new(url)
    handler_hash = Digest::MD5.hexdigest(handler.to_yaml)

    delay = if delay.is_a? Fixnum
      delay.from_now
    elsif delay.is_a? DateTime
      delay
    else
      300.seconds.from_now
    end
    Delayed::Job.enqueue(handler, run_at: delay)
  end

  def rescue_block(str)
    crawled_pages = @domain.pages.where('last_crawled is not null').count
    @domain.last_crawled = DateTime.now
    if str.include? "general SOCKS server failure"
      Rails.logger.debug(str)
        @domain.missed_attempts += 3
        if @domain.missed_attempts >= 5 && crawled_pages == 0
          @domain.blocked = true
        end
        @domain.save
        requeue(@url, @domain.crawl_delay.seconds) and return true
      elsif str.include? "Host unreachable"
        Rails.logger.debug(str)
        @domain.missed_attempts += 1
        if @domain.missed_attempts >= 5 && crawled_pages == 0
          @domain.blocked = true
        end
        @domain.save
        requeue(@url, @domain.crawl_delay.seconds) and return true
      elsif str.include? "Redirect limit of 20 reached"
        Rails.logger.debug(str)
        @domain.missed_attempts += 1
        if @domain.missed_attempts >= 5 && crawled_pages == 0
          @domain.blocked = true
        end
        @domain.save
        requeue(@url, @domain.crawl_delay.seconds) and return true
      elsif str.include? 'connection not allowed by ruleset'
        Rails.logger.debug "Blocking an invalid domain"
        @domain.blocked = true
        @domain.save
      elsif str.include? 'TTL expired'
        Rails.logger.debug(str)
        @domain.missed_attempts += 1
        if @domain.missed_attempts >= 5 && crawled_pages == 0
          @domain.blocked = true
        end
        @domain.save
        requeue(@url, @domain.crawl_delay.seconds) and return true
      elsif str.include? 'connection refused'
        sleep(30)
        requeue(@url, @domain.crawl_delay.seconds) and return true
      end
    end
end