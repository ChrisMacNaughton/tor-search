class Tracker
  attr_accessor :piwik_url
  def initialize(request, search = nil, action = nil, site_id = 5)
    #debugger
    @search = search
    @action = "#{request.params[:controller]}/"
    if action.nil?
      @action += "#{request.params[:action]}"
    else
      @action += "#{action}"
    end
    self.piwik_url = "http://piwik.nuradu.com/piwik.php"
    @user_id = request.session["session_id"]
    @url = request.url
    @referrer = request.referrer
    @idsite = site_id
  end
  def track!
    Rails.logger.info "Tracking a pageview!"
    Rails.logger.debug options
    response
  end
  private
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
  def options
    {
      idsite: @idsite,
      rec: 1,
      apiv: 1,
      url: @url,
      urlref: @referrer,
      action_name: @action,
      :cid => @user_id,
      search: @search.try('[]',:term),
      search_count: @search.try('[]',:count),
      token_auth: '15a609cdc47efd8b8fe10bf568935ea6'
    }.delete_if{|k,v| v.nil?}
  end
  def uri
    URI.parse(self.piwik_url)
  end
end