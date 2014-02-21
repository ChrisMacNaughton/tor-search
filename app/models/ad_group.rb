class AdGroup < ActiveRecord::Base
  belongs_to :ad_campaign
  belongs_to :advertiser
  has_many :ad_group_keywords, dependent: :destroy
  has_many :ads, dependent: :destroy
  attr_accessible :name, :paused, :advertiser, :advertiser_id, :ad_campaign, :ad_campaign_id

  scope :without_keywords,
    where("NOT EXISTS (select 'x' FROM ad_group_keywords WHERE ad_group_id = ad_groups.id LIMIT 1)")

  def refresh_counts!
    self.clicks_count = ads.sum(&:ad_clicks_count)
    self.views_count = ads.sum(&:ad_views_count)

    self.ctr = if self.views_count > 0
      self.clicks_count / self.views_count.to_f
    else
      0
    end

    if self.views_count > 0
      sum = 0
      ads.each do |ad|
        sum += ad.ad_views.sum(:position)
      end
      self.avg_position = sum / self.views_count.to_f
    else
      self.avg_position = 0
    end

    save!
  end
end
