class AdGroupKeyword < ActiveRecord::Base
  belongs_to :ad_group
  belongs_to :keyword

  attr_accessible :ad_group_id, :ad_group, :keyword_id, :keyword, :bid
  validates :ad_group_id, uniqueness: { scope: :keyword_id }
end
