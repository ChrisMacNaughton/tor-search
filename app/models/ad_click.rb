# encoding: utf-8
# AdClicks track clicks on ads
class AdClick < ActiveRecord::Base
  belongs_to :ad, counter_cache: true
  belongs_to :query
  belongs_to :search
  attr_accessible :ad, :ad_id, :bid, :query, :search, :query_id, :search_id
end
