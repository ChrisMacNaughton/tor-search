class AdView < ActiveRecord::Base
  belongs_to :ad
  belongs_to :query
  attr_accessible :query_id, :ad_id
end
