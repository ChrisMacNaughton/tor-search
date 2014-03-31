# encoding: utf-8

require "#{Rails.root}/lib/matcher/matchers/generic_matcher"

# generic matcher initializes the matcher

class UserAgentMatcher < GenericMatcher

  def self.matches
    ['useragent', 'user agent', 'header', 'request header']
  end

  def weight
    15
  end

  def execute
    {
      name: 'Request Headers',
      method: 'title',
      type: 'ordered',
      data: data,
      link: '',
      weight: weight
    }
  end

  def data
    d = {}
    d[:user_agent] = @request.user_agent
    #d.merge!(@request.headers.reject { |k, v| k.include? '.' })
    @request.headers.each {|k,v| d[k] = v unless k.include? '.'}
    HashWithIndifferentAccess.new(reject_headers(d))
  end

  def reject_headers(data)
    # rubocop:disable all
    [
      :'HTTP_REFERER' , :'REQUEST_PATH' , :'ORIGINAL_FULLPATH' , :'HTTP_COOKIE', :'PATH_INFO' , :'HTTP_USER_AGENT' , :'SERVER_SOFTWARE',
      :'HTTP_X_REQUESTED_WITH' , :'HTTP_X_CSRF_TOKEN' , :'HTTP_IF_NONE_MATCH', :'default_strategies', :'warden', :'scope_defaults',
      :'intercept_401', :'failure_app'
    ].each do |key|
      data.delete(key)
    end
    # rubocop:enable all
    data
  end
end
