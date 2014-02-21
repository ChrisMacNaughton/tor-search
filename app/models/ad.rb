# encoding: utf-8
# a specific ad that can be shown
class Ad < ActiveRecord::Base
  PROTOCOL_ID_HTTP = 0
  PROTOCOL_ID_HTTPS = 1
  PROTOCOL_IDS = [PROTOCOL_ID_HTTPS , PROTOCOL_ID_HTTP]
  belongs_to :ad_group
  belongs_to :advertiser
  has_one :ad_campaign, through: :ad_group

  has_many :ad_views
  has_many :ad_clicks

  has_many :ad_group_keywords, through: :ad_group

  # keyword_id is for tracking an ad selected from a keyword
  # include_path is for auto generated ads to know their path with the redirect
  attr_accessible :bid, :title, :disabled, :protocol_id, :path, :approved,
                  :ppc, :display_path, :line_1, :line_2, :include_path,
                  :advertiser, :ad_group_id
  validates :advertiser_id, presence: true
  validates :path, presence: true
  validates :title, presence: true
  validates :bid, presence: true
  validates :protocol_id, inclusion: { in: PROTOCOL_IDS }

  # ad display validations
  validates :title, length: { minimum: 5, maximum: 25 }
  validates :line_1, length: { maximum: 35 }
  validates :line_2, length: { maximum: 35 }
  validates :display_path, length: { maximum: 35 }

  before_create :disable_ad
  before_save :check_onion
  before_save :trim_off_http
  # scope :available, lambda {
  #   where(approved: true).where(disabled: false)
  # }
  attr_accessor :include_path, :keyword_id

  scope :enabled,
    where(approved: true, disabled: false, ad_groups: {paused: false}, ad_campaigns: {paused: false}) \
    .joins(ad_group: :ad_campaign)

  def self.without_keywords
    ad_groups = AdGroup.without_keywords
    return [] if ad_groups.nil?
    ad_group_ids = ad_groups.map(&:id)
    advertiser_ids = ad_groups.map(&:advertiser_id)
    ad_group_ads = Ad.where(ad_group_id: ad_group_ids).group_by(&:ad_group_id)
    return [] if ad_group_ads.nil?
    advertisers = Advertiser.where(id: advertiser_ids)
    ads = []
    ad_group_ads.map do |ad_group_id, ad_group|

      ad_options = ad_group.select do |ad|
        adv = advertisers.detect{|a| ad.advertiser_id = a.id}
        ad.approved? && !ad.disabled? && ad.bid > 0 && ad.bid <= adv.balance
      end.compact
      next if ad_options.empty?
      ads << ad_options.sample
    end

    ads
  end

  def self.with_keywords(keywords = [])
    keywords = [*keywords]
    keywords = Keyword.where('LOWER(word) in (?)', keywords)
    keyword_ids = keywords.map(&:id)
    return [] if keyword_ids.nil?

    ad_group_keywords = AdGroupKeyword.valid.where(keyword_id: keyword_ids).where('bid > 0')
    return [] if ad_group_keywords.nil?

    ad_groups = AdGroup.where(id: ad_group_keywords.map(&:ad_group_id).uniq, paused: false)
    return [] if ad_groups.nil?

    ad_group_ads = ad_groups.map(&:ads)
    return [] if ad_group_ads.nil?

    ads = []
    ad_group_ads.map do |ad_group|
      ad_options = ad_group.select do |ad|
        ad.approved? && !ad.disabled? && !ad.ad_group.ad_campaign.paused?
      end.compact
      next if ad_options.empty?
      ad = ad_options.sample
      keyword = ad_group_keywords.detect{|k| k.ad_group_id == ad.ad_group_id}
      ad.bid = keyword.bid
      keyword = keywords.detect{|k| k.id = keyword.keyword_id}
      ad.keyword_id = keyword.id
      ads << ad
    end

    ads
  end

  def disable_ad
    self.disabled = true
  end

  def check_onion
    check_path = path.gsub(%r(https?://), '')
    self.onion = !!(check_path =~ /^[2-7a-zA-Z]{16}\.onion/)
    true
  end

  def trim_off_http
    self.path = path.gsub(/https?:\/\//, '')
    true
  end

  def protocol
    if protocol_id == PROTOCOL_ID_HTTP
      'http://'
    elsif protocol_id == PROTOCOL_ID_HTTPS
      'https://'
    end
  end

  def ctr
    if ad_views_count > 0
      ad_clicks_count / ad_views_count.to_f * 100
    else
      0
    end
  end

  def avg_position
    @sum ||= ad_views.average(:position)
  end

  def status
    if approved?
      if disabled?
        "Paused"
      else
        "Active"
      end
    else
      "Pending"
    end
  end

  def pending?
    !approved?
  end

  def paused?
    approved? && disabled?
  end

  def legacy?
    created_at.present? && created_at < DateTime.parse('February 10, 2014')
  end

  def valid_bid?
    bid <= advertiser.balance && bid > 0
  end
end
