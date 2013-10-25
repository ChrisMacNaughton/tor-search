# encoding: utf-8
# ad AdKeyword maps an ad to a keyword
class AdKeyword < ActiveRecord::Base
  belongs_to :ad
  belongs_to :keyword
  attr_accessible :bid, :ad_id, :keyword_id, :keyword, :ad

  validates :keyword_id, uniqueness: { scope: :ad_id }

  delegate :word, to: :keyword
end
