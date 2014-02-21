class AdGroup < ActiveRecord::Base
  belongs_to :ad_campaign
  belongs_to :advertiser
  has_many :ad_group_keywords, dependent: :destroy
  has_many :ads, dependent: :destroy
  attr_accessible :name, :paused, :advertiser, :advertiser_id, :ad_campaign, :ad_campaign_id

  scope :without_keywords,
    where("NOT EXISTS (select 'x' FROM ad_group_keywords WHERE ad_group_id = ad_groups.id LIMIT 1)")

  def refresh_counts!

    clicks = ads.sum(&:ad_clicks_count)
    views = ads.sum(&:ad_views_count)

    click_through = if views > 0
      clicks / views.to_f
    else
      0
    end

    if views > 0
      sum = 0
      ads.each do |ad|
        sum += ad.ad_views.sum(:position)
      end
      avg = sum / views.to_f
    else
      avg = 0
    end
    AdGroup.where(id: self.id).update_all(clicks_count: clicks, views_count: views, ctr: click_through, avg_position: avg)
  end
end
