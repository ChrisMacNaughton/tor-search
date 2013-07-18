require "#{Rails.root}/lib/tor.rb"

module Robotstxt

  # Check if the <tt>URL</tt> is allowed to be crawled from the current <tt>Robot_id</tt>.
  # Robotstxt::Allowed? returns <tt>true</tt> if the robots.txt file does not block the access to the URL.
  #
  #  Robotstxt.allowed?('http://www.simonerinzivillo.it/', 'rubytest')
  #
  def self.allowed?(url, robot_id, domain, tor = Tor.new)
    r = Robotstxt::Parser.new(robot_id, tor)
    url.gsub!(' ', '%20')
    Rails.logger.debug("Checking if we're allowed to crawl #{url}")
    if domain.robots_txt.nil? && r.get(url)
      domain.robots_txt = r.body
      r.allowed?(url)
    elsif !domain.robots_txt.nil?
      r.body = domain.robots_txt
      r.allowed?(url)
    elsif !r.found
      domain.robots_txt = ""
      true
    end
  end
  def self.crawl_delay(robot_id, domain, tor = Tor.new)
    r = Robotstxt::Parser.new(robot_id, tor)
    Rails.logger.debug("Checking crawl delay")
    if domain.robots_txt.nil? && r.get(url)
      domain.robots_txt = r.body
      r.crawl_delay
    elsif !domain.robots_txt.nil?
      r.body = domain.robots_txt
      r.crawl_delay
    elsif !r.found
      0.5
    end
  end
  # Analyze the robots.txt file to return an <tt>Array</tt> containing the list of XML Sitemaps URLs.
  #
  #  Robotstxt.sitemaps('http://www.simonerinzivillo.it/', 'rubytest')
  #
  def self.sitemaps(url, robot_id, domain, tor = Tor.new)

    r = Robotstxt::Parser.new(robot_id, tor)
    if domain.robots_txt.nil? && r.get(url)
      domain.robots_txt = r.body
      r.sitemaps
    elsif !domain.robots_txt.nil?
      r.body = domain.robots_txt
      r.sitemaps
    elsif !r.found
      domain.robots_txt = ""
      []
    end

  end

end

#
# = Ruby Robotstxt
#
# An Ruby Robots.txt parser.
#
#
# Category::    Net
# Package::     Robotstxt
# Author::      Simone Rinzivillo <srinzivillo@gmail.com>
# License::     MIT License
#
#--
#
#++

require 'net/http'
require 'uri'


module Robotstxt
  class Parser
    attr_accessor :robot_id
    attr_reader :found, :body, :sitemaps, :rules

    # Initializes a new Robots::Robotstxtistance with <tt>robot_id</tt> option.
    #
    # <tt>client = Robotstxt::Robotstxtistance.new('my_robot_id')</tt>
    #
    def initialize(robot_id = nil, tor)
      @tor = tor
      @robot_id = '*'
      @rules = []
      @sitemaps = []
      @crawl_delay = 2
      @robot_id = robot_id.downcase unless robot_id.nil?

    end

    # Requires and parses the Robots.txt file for the <tt>hostname</tt>.
    #
    #  client = Robotstxt::Robotstxtistance.new('my_robot_id')
    #  client.get('http://www.simonerinzivillo.it')
    #
    #
    # This method returns <tt>true</tt> if the parsing is gone.
    #
    def get(hostname)

      begin
        response = @tor.get(hostname + '/robots.txt')

        case response
          when Net::HTTPSuccess then
          @found = true
          @body = response.body
          parse()

          else
          @found = false
        end

        return @found

      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET => e

      end

    end
    def crawl_delay
      @body.each_line {|r|
        case r
          when /^\s*crawl-delay\s*:.+$/
            @crawl_delay = r.split(':')[1].strip
        end
      }

      @crawl_delay = 2 if @crawl_delay == "" || @crawl_delay.nil?
      @crawl_delay
    end
    def body= (body)
      @body = body
    end
    def body
      @body
    end
    # Check if the <tt>URL</tt> is allowed to be crawled from the current Robot_id.
    #
    #  client = Robotstxt::Robotstxtistance.new('my_robot_id')
    #  if client.get('http://www.simonerinzivillo.it')
    #    client.allowed?('http://www.simonerinzivillo.it/no-dir/')
    #  end
    #
    # This method returns <tt>true</tt> if the robots.txt file does not block the access to the URL.
    #
    def allowed?(var)
      is_allow = true
      url = URI.parse(var)
      querystring = (!url.query.nil?) ? '?' + url.query : ''
      url_path = url.path + querystring

      @rules.each {|ua|

        if @robot_id == ua[0] || ua[0] == '*'

          ua[1].each {|d|

            is_allow = false if url_path.match('^' + d ) || d == '/'

          }

        end

      }
      is_allow
    end

    # Analyze the robots.txt file to return an <tt>Array</tt> containing the list of XML Sitemaps URLs.
    #
    #  client = Robotstxt::Robotstxtistance.new('my_robot_id')
    #  if client.get('http://www.simonerinzivillo.it')
    #    client.sitemaps.each{ |url|
    #    puts url
    #  }
    #  end
    #
    def sitemaps
      @sitemaps
    end

    # This method returns <tt>true</tt> if the Robots.txt parsing is gone.
    #
    def found?
      !!@found
    end


    private

    def parse()
      @body = @body.downcase

      @body.each_line {|r|

        case r
          when /^#.+$/

          when /^\s*user-agent\s*:.+$/

          @rules << [ r.split(':')[1].strip, [], []]

          when /^\s*useragent\s*:.+$/

          @rules << [ r.split(':')[1].strip, [], []]

          when /^\s*disallow\s*:.+$/
          r = r.split(':')[1].strip
          @rules.last[1]<< r.gsub(/\*/,'.+') if r.length > 0

          when /^\s*allow\s*:.+$/
          r = r.split(':')[1].strip
          @rules.last[2]<< r.gsub(/\*/,'.+') if r.length > 0

          when /^\s*sitemap\s*:.+$/
          @sitemaps<< r.split(':')[1].strip + ((r.split(':')[2].nil?) ? '' : r.split(':')[2].strip) if r.length > 0
        end
      }
    end
  end
end