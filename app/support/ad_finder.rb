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
      @selected_ads = (ads_by_keyword).uniq.sort_by(&:bid).reverse.take(limit)
      Rails.logger.info "\tFound #{@selected_ads.count} ads"
    end
    @selected_ads
  end

  protected

  def ads_by_keyword
    if @keyword_ads.nil?
      @keyword_ads = []
      keyword_ids = Keyword.where('LOWER(word) in (?)', query_words).pluck(:id)
      if keyword_ids.any?
        ad_group_keywords = AdGroupKeyword \
          .where(keyword_id: keyword_ids) \
          .where('bid <= advertisers.balance') \
          .joins(:ad_group) \
          .joins('LEFT JOIN advertisers ON advertisers.id = ad_groups.advertiser_id') \
          .order('bid desc').limit(limit * 2)
        group_ids = ad_group_keywords.map(&:ad_group_id)
        groups = AdGroup.where(id: group_ids)

        ads = groups.map(&:ads).flatten.shuffle
        advertisers = []
        ads.each do |ad|
          kw = ad_group_keywords.detect{|k| k.ad_group_id == ad.ad_group_id }
          ad.keyword_id = kw.id
          ad.bid = kw.bid * 1.2
          @keyword_ads << ad unless advertisers.include? ad.advertiser_id
          advertisers << ad.advertiser_id
        end
      end
      @keyword_ads = @keyword_ads[0..limit]
    end
    @keyword_ads
  end

  def generic_ads
    if @generic_ads.nil?
      if ads_by_keyword.count >= limit
        @generic_ads = []
      else
        @generic_ads ||= Ad.limit(limit - ads_by_keyword.count).available.joins(:advertiser). \
          where('advertisers.balance >= ads.bid') \
          .where("(select count(*) from ad_keywords where ad_id = ads.id) = 0") \
          .where('ads.bid > 0') \
          .order('bid desc, created_at asc').map{|ad| ad.bid = ad.bid * 0.8; ad}
      end
    end
    @generic_ads
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