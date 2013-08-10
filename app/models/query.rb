class Query < ActiveRecord::Base
  attr_accessible :term

  has_many :searches
end
