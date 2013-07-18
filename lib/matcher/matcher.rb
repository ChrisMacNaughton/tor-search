Dir.glob("#{Rails.root}/lib/matcher/matchers/*").each do |f|
  require f
end
class Matcher
  MATCHERS = ["Bitcoin","UserAgent"]
  def initialize(term, request)
    @term = term
    @request = request
  end
  def execute
    if matches?
      res = []
      matches.each do |m|
        res << m
      end
      res = res.sort_by{|m| m[:weight] }
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
        matcher = "#{t}Matcher".constantize
        matcher.matches.each do |match|
          if @term.include? match
            next if @matches.count > 2
            @matches << matcher.new(@request).execute
            break
          end
        end
      end
    else
      @matches
    end
    @matches
  end
end