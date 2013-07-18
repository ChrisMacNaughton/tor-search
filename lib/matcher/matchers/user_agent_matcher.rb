require "#{Rails.root}/lib/matcher/matchers/generic_matcher"
class UserAgentMatcher < GenericMatcher
  def self.matches
    ['useragent', 'user agent', 'header','request header']
  end
  def weight
    15
  end
  def execute
    data = HashWithIndifferentAccess.new({})
    data[:user_agent] = @request.user_agent
    data.merge!(@request.headers.reject{|k,v| k.include? '.'})
    [:'REQUEST_PATH',:'ORIGINAL_FULLPATH',:'HTTP-COOKIE', :'HTTP_USER_AGENT':'SERVER_SOFTWARE',:'HTTP_X_REQUESTED_WITH',:'HTTP_X_CSRF_TOKEN'].each do |key|
      data.delete(key)
    end
    {
      name: "Request Headers",
      method: 'title',
      type: 'ordered',
      data: data,
      weight: weight
    }
  end
end