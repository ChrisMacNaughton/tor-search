class Bang
  attr_reader :query
  def initialize(query)
    @query = query
  end

  def redirect_target
    self.send(bang.to_sym)
  end

  def has_target?
    bang && self.respond_to?(bang.to_sym)
  end
  def amazon
    url = "http://www.amazon.com/gp/search?ie=UTF8&camp=1789&creative=9325&index=aps&keywords=#{query.gsub("!#{bang}", '').lstrip.rstrip.gsub(/\s/, '+')}&linkCode=ur2&tag=tor-search-20"
  end
  private

  def bang
    if @bang.nil?
      @bang = query.match(/\s{0,1}!(\w*)\s{0,1}/).to_a.select{|a| !a.include? '!' }.first
    end
    @bang
  end

end