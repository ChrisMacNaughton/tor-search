class AdView < ActiveRecord::Base
  belongs_to :ad, counter_cache: true
  belongs_to :query
  attr_accessible :query_id, :ad_id, :position
end
