class Tracker

  attr_accessor :piwik_url
  attr_reader :request, :site_id
  def initialize(request, search = nil, action = nil, site_id = 5)
    #debugger
    self.piwik_url = "http://piwik.nuradu.com/piwik.php"
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
    Rails.logger.info "Tracking a pageview!"
    Rails.logger.debug options
    Rails.logger.debug response.body
  end

  private

  def user_id
    session[:piwik_session_id] ||= SecureRandom.hex[0...16]
  end

  def http
    Net::HTTP.new(uri.host, uri.port)
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
    {
      idsite: site_id,
      rec: 1,
      apiv: 1,
      rand: SecureRandom.hex,
      url: url,
      urlref: referrer,
      action_name: @action,
      ua: user_agent,
      search: @search.try('[]',:term),
      search_count: @search.try('[]',:count),
      token_auth: '3c5ab420b37daa3c643fca412a1f8da8',
      cid: user_id,
      cip: '',
    }.delete_if{|k,v| v.nil?}
  end

  def uri
    URI.parse(self.piwik_url)
  end
end

