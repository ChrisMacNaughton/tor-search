class TrendingSearch < ActiveRecord::Base
  belongs_to :query
  attr_accessible :volume
end
