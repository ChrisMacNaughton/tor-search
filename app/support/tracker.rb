# encoding: utf-8
# class built to track visits iin Piwik
class Tracker

  attr_reader :request, :site_id
  attr_writer :auth_token, :piwik_url

  def piwik_url
    @piwik_url ||= 'http://piwik.nuradu.com/piwik.php'
  end

  def auth_token
    @auth_token ||= '3c5ab420b37daa3c643fca412a1f8da8'
  end

  def initialize(request, search = nil, action = nil, site_id = 5)
    @site_id = site_id
    @request = request
    @search = search
    @action = "#{request.params[:controller]}/"
    if action.nil?
      @action += "#{request.params[:action]}"
    else
      @action += "#{action}"
    end
  end

  def track!
    Rails.logger.debug 'Tracking a pageview!'
    Rails.logger.debug options
    Rails.logger.debug response.body
  end

  def track_later!
    Tracker.delay.track!(options, uri)
    true
  end

  def self.track!(options, uri)
    http = Net::HTTP.new(uri.host, uri.port)

    if uri.scheme == 'https'
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    Rails.logger.debug "Tracking a visit:"
    options.delete(:cdt)
    Rails.logger.debug options
    result = http.request(Net::HTTP::Get.new("#{uri.request_uri}?#{options.to_query}"))
    Rails.logger.debug "Received: " + result.body
  end

  private

  def user_id
    session[:piwik_session_id] ||= SecureRandom.hex[0...16]
  end

  def http
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http
  end

  def net_request
    Net::HTTP::Get.new(path)
  end

  def path
    @path ||= "#{uri.request_uri}?#{options.to_query}"
  end

  def response
    http.request(net_request)
  end

  def method_missing(meth, *args)
    request.send(meth.to_sym, *args)
  end

  def respond_to_missing?(meth, *args)
    request.respond_to? meth
  end

  def options
    default_opts.merge(
      idsite: site_id,
      action_name: @action,
      ua: user_agent,
      search: @search.try('[]', :term),
      search_count: @search.try('[]', :count),
      cid: user_id,
      cip: '',
    ).delete_if { |k, v| v.nil? }
  end

  def default_opts
    {
      rec: 1,
      apiv: 1,
      rand: SecureRandom.hex,
      url: url,
      urlref: referrer,
      token_auth: auth_token,
    }
  end

  def uri
    URI.parse(piwik_url)
  end
end
