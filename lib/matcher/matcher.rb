# encoding: utf-8

Dir.glob("#{Rails.root}/lib/matcher/matchers/*").each do |f|
  require f
end

# Matcher is what is used to find instant matches to queries
class Matcher
  MATCHERS = %w(Bitcoin UserAgent)

  def initialize(term, request)
    @term = term
    @request = request
  end

  def execute
    if matches?
      res = []
      matches.each do |m|
        res << m unless m.empty?
      end
      res = res.sort_by { |m| m[:weight] }
    else
      []
    end
    res
  end

  def matches?
    !matches.empty?
  end

  def matches
    if @matches.nil?
      @matches = []
      MATCHERS.each do |t|
        add_matcher(t)
      end
    else
      @matches
    end
    @matches
  end

  private

  def add_matcher(t)
    matcher = "#{t}Matcher".constantize
    matcher.matches.each do |match|
      if @term.include? match
        next if @matches.count > 2
        @matches << matcher.new(@request, @term).execute
        break
      end
    end
  end
end
