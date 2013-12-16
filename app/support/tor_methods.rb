module TorMethods
  def request_is_oniony
    if !!(request.host =~ /onion/)
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

  def request_ip_is_exit?
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

  def read_through_cache(cache_key, expires_in, &block)
    # Attempt to fetch the choice values from the cache,
    # if not found then retrieve them and stuff the results into the cache.
    if TorSearch::Application.config.action_controller.perform_caching
      Rails.cache.fetch(cache_key, expires_in: expires_in, &block)
    else
      yield
    end
  end
end