class AdGroup < ActiveRecord::Base
  belongs_to :ad_campaign
  belongs_to :advertiser
  has_many :ads
  attr_accessible :name, :paused, :advertiser, :advertiser_id, :ad_campaign, :ad_campaign_id

  def clicks_count
    ads.sum(&:ad_clicks_count)
  end

  def views_count
    0
  end

  def ctr
    0
  end

  def avg_position
    0
  end

end
