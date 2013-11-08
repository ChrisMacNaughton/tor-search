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
      @selected_ads = (ads_by_keyword | generic_ads).uniq.sort_by(&:bid).reverse.take(limit).map(&:reload)
      Rails.logger.info "\tFound #{@selected_ads.count} ads"
    end
    @selected_ads
  end

  protected

  def ads_by_keyword
    if @keyword_ads.nil?
      @keyword_ads = Ad.select("ads.*").limit(limit).available \
        .joins(:advertiser, ad_keywords: :keyword) \
        .where('advertisers.balance > ad_keywords.bid') \
        .where("LOWER(keywords.word) in (?)", query_words).order('bid desc, created_at asc')
      @keyword_ads.map do |ad|
        ad.keyword_id = ad.ad_keywords.joins(:keyword) \
          .where("LOWER(keywords.word) in (?)", query_words).first.id
      end
    end
    @keyword_ads
  end

  def generic_ads
    @generic_ads ||= Ad.limit(limit).available.joins(:advertiser). \
      where('advertisers.balance > ads.bid') \
      .where("(select count(*) from ad_keywords where ad_id = ads.id) = 0") \
      .order('bid desc, created_at asc').map{|ad| ad.bid = ad.bid * 0.8; ad}
  end

  def query_words
    tokenize(query)
  end

  private

  def tokenize str1
    str = str1.split(/\s/)

    opts = []
    opts << str.join(' ').downcase

    (str.count - 1).times do |i|
      combinations = str.combination(i+1).to_a.map{|a| a.join(' ').downcase}
      opts << combinations
    end

    opts.flatten.compact.uniq
  end
end
# rubocop:disable all