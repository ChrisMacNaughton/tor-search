# encoding: utf-8

# Bang is used to identify queries that we can redirect the query on
class Bang
  attr_reader :query

  def initialize(query)
    @query = query
  end

  def redirect_target
    send(bang.to_sym)
  end

  def has_target?
    bang && self.respond_to?(bang.to_sym)
  end

  def amazon
    "http://www.amazon.com/gp/search?#{amazon_args}"
  end

  def bang
    if @bang.nil?
      @bang = query.match(/\s{0,1}@(\w*)\s{0,1}/).to_a.select do |a|
        !a.include? '@'
      end.first
    end
    @bang
  end

  private

  def amazon_args
    "#{default_options}&keywords=#{keywords}&linkCode=ur2&tag=#{tag}"
  end

  def default_options
    'ie=UTF8&camp=1789&creative=9325&index=aps'
  end

  def keywords
    term.gsub(/\s/, '+')
  end

  def tag
    'tor-search-20'
  end

  def term
    query.gsub("@#{bang}", '').lstrip.rstrip
  end

end
