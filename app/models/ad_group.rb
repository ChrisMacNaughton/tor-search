class AdGroup < ActiveRecord::Base
  belongs_to :ad_campaign
  belongs_to :advertiser
  has_many :ads
  attr_accessible :name, :paused, :advertiser, :advertiser_id, :ad_campaign, :ad_campaign_id
end
