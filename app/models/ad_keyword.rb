class AdKeyword < ActiveRecord::Base
  belongs_to :ad
  belongs_to :keyword
  attr_accessible :bid, :ad_id, :keyword_id
end
