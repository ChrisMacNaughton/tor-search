class AdGroup < ActiveRecord::Base
  belongs_to :ad_campaign
  belongs_to :advertiser
  has_many :ad_group_keywords, dependent: :destroy
  has_many :ads, dependent: :destroy
  attr_accessible :name, :paused, :advertiser, :advertiser_id, :ad_campaign, :ad_campaign_id

  scope :without_keywords,
    where("NOT EXISTS (select 'x' FROM ad_group_keywords WHERE ad_group_id = ad_groups.id LIMIT 1)")

  def self.refresh_counts!
    AdGroup.connection.execute <<-SQL
      WITH ad_stats AS (
        select sum(ad_views_count) as views_count, sum(ad_clicks_count) as clicks_count, ad_group_id
        from ads
        group by ad_group_id
      ), averages AS (
        SELECT AVG(position) as avg_position, ads.ad_group_id
        FROM ad_views
        LEFT JOIN ads ON ad_views.ad_id = ads.id
        GROUP BY ads.ad_group_id
      )
      UPDATE ad_groups SET clicks_count = (
        select clicks_count from ad_stats
        WHERE ad_stats.ad_group_id = ad_groups.id
      ), views_count = (
        select views_count from ad_stats
        WHERE ad_stats.ad_group_id = ad_groups.id
      ), ctr = (
        CASE WHEN COALESCE(views_count, 0) > 0
        THEN COALESCE(clicks_count, 0) / views_count::decimal
        ELSE
        0
        END
      ), avg_position = (
        SELECT avg_position
        FROM averages
        WHERE averages.ad_group_id = ad_groups.id
      )::decimal
    SQL
  end
end
