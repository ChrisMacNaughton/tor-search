class AdGroupKeyword < ActiveRecord::Base
  belongs_to :ad_group
  belongs_to :keyword
  has_many :ads, through: :ad_group
  attr_accessible :ad_group_id, :ad_group, :keyword_id, :keyword, :bid, :paused
  validates :ad_group_id, uniqueness: { scope: [:keyword_id, :ad_group_id] }

  scope :valid,
    where('ad_group_keywords.bid <= advertisers.balance') \
    .joins(:ad_group) \
    .joins('LEFT JOIN advertisers ON advertisers.id = ad_groups.advertiser_id')

  delegate :word, to: :keyword, allow_nil: true
  def status
    if paused?
      "Paused"
    else
      "Active"
    end
  end

  def ctr
    if views.present? && views > 0 && clicks.present? && clicks > 0
      clicks / views.to_f
    else
      0
    end * 100
  end

  def self.refresh_counts!
    AdGroupKeyword.connection.execute(
      <<-SQL
WITH click_counts AS (
  SELECT count(ad_clicks.keyword_id) as clicks_count, ad_clicks.keyword_id as keyword_id
  FROM ad_clicks
  LEFT JOIN ads
  ON ad_clicks.ad_id = ads.id
  WHERE ads.deleted_at IS NULL
  GROUP BY ad_clicks.keyword_id
), view_counts AS (
  SELECT count(ad_views.keyword_id) as views_count, ad_views.keyword_id as keyword_id
  FROM ad_views
  LEFT JOIN ads
  ON ad_views.ad_id = ads.id
  WHERE ads.deleted_at IS NULL
  GROUP BY ad_views.keyword_id
), keyword_stats AS (
  SELECT click_counts.clicks_count as clicks, view_counts.views_count AS views, view_counts.keyword_id
  FROM click_counts
  JOIN view_counts ON view_counts.keyword_id = click_counts.keyword_id
)
UPDATE ad_group_keywords
  SET clicks = COALESCE((SELECT clicks FROM keyword_stats WHERE keyword_stats.keyword_id = ad_group_keywords.keyword_id), 0),
  views = COALESCE((SELECT views FROM keyword_stats WHERE keyword_stats.keyword_id = ad_group_keywords.keyword_id), 0)
      SQL
    )
  end
end
