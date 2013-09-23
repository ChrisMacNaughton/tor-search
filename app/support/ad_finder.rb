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
      @selected_ads = (ads_by_keyword | generic_ads).uniq.sort{|f,s| s.bid <=> f.bid }.map(&:reload).take(limit)
    end
    @selected_ads
  end
  protected
  def ads_by_keyword
    @keyword_ads ||= Ad.limit(limit).available.joins(:advertiser, ad_keywords: :keyword). \
      where('advertisers.balance > ads.bid').where("keywords.word in (?)", query_words)
  end
  def generic_ads
    @generic_ads ||= Ad.limit(limit).available.joins(:advertiser). \
      where('advertisers.balance > ads.bid').where("(select count(*) from ad_keywords where ad_id = ads.id) = 0").order(:bid, :created_at).map{|ad| ad.bid = ad.bid / 2; ad}
  end
  def query_words
    query.split(' ')
  end
end