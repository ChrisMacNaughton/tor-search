class AdClick < ActiveRecord::Base
  belongs_to :ad
  belongs_to :query
  attr_accessible :ad, :bid, :query
end
