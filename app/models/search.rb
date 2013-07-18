class Search < ActiveRecord::Base
  attr_accessible :query, :results_count
  has_many :clicks
end
