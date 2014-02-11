class AdGroupKeyword < ActiveRecord::Base
  belongs_to :ad_group
  belongs_to :keyword
  has_many :ads, through: :ad_group
  attr_accessible :ad_group_id, :ad_group, :keyword_id, :keyword, :bid
  validates :ad_group_id, uniqueness: { scope: :keyword_id }

  scope :valid,
    where('ad_group_keywords.bid <= advertisers.balance') \
    .joins(:ad_group) \
    .joins('LEFT JOIN advertisers ON advertisers.id = ad_groups.advertiser_id')
end
