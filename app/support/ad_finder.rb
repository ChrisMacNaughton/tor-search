# rubocop:disable all
# AdFinder is used to find ads that match a query
class AdFinder
  attr_accessor :query
  attr_accessor :limit

  def initialize(query,limit=5)
    self.query = query
    self.limit = limit
  end

  def ads
    if @selected_ads.nil?
      Rails.logger.info "Fetching ads for #{self.query}"
      @selected_ads = (ads_by_keyword | generic_ads).uniq.sort_by(&:bid).reverse.take(limit)
      Rails.logger.info "\tFound #{@selected_ads.count} ads"
    end
    @selected_ads
  end

  protected

  def ads_by_keyword
    @keyword_ads ||= Ad.with_keywords(query_words)
  end

  def generic_ads
    @generic_ads ||= Ad.without_keywords
  end

  def query_words
    tokenize(query)
  end

  private

  def tokenize str1
    str = str1.split(/\s/)

    opts = []
    opts << str.join(' ').downcase.singularize

    (str.count - 1).times do |i|
      combinations = str.combination(i+1).to_a.map{|a| a.join(' ').downcase}
      opts << combinations
    end

    opts.flatten.compact.uniq
  end
end
# rubocop:disable all