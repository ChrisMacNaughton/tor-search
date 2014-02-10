class AdCampaign < ActiveRecord::Base
  attr_accessible :name, :status, :paused, :advertiser, :advertiser_id
  belongs_to :advertiser
  has_many :ad_groups
end
