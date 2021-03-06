class AdCampaign < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :name, :status, :paused, :advertiser, :advertiser_id, :default_bid
  belongs_to :advertiser
  has_many :ad_groups, dependent: :destroy
  has_many :ads, through: :ad_groups
end
