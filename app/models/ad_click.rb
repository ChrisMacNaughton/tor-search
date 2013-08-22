class AdClick < ActiveRecord::Base
  belongs_to :ad, counter_cache: true
  belongs_to :query
  attr_accessible :ad, :bid, :query
end
