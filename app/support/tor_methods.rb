module TorMethods
  include CacheSupport
  def request_is_oniony
    if @request_is_oniony.nil?
      @request_is_oniony = if !!(request.host =~ /onion/)
        if is_tor2web?
          'tor2web'
        else
          'tor'
        end
      else
        if request_ip_is_exit?
          'tor_over_clear'
        else
          'clear'
        end
      end
    end
    @request_is_oniony
  end

  def request_ip_is_exit?
    return false if Rails.env.test?
    ips = read_through_cache('exit_ips', 24.hours) do
      url = URI('https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=173.49.88.241&port=443')
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      r = Net::HTTP::Get.new(url.request_uri)
      response = http.start { |h| h.request(r) }
      response.body.split("\n").reject{|w| w[0] == '#'}
    end
    ips.include? request.ip
  end

  def is_tor2web?
    request.headers['X_TOR2WEB'] == 'encrypted'
  end
end