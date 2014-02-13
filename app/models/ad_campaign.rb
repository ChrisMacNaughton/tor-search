class AdCampaign < ActiveRecord::Base
  attr_accessible :name, :status, :paused, :advertiser, :advertiser_id, :default_bid
  belongs_to :advertiser
  has_many :ad_groups, dependent: :destroy
end
