class Search < ActiveRecord::Base
  include SearchByKeyedScopes
  attr_accessible :query, :results_count
  has_many :clicks

  sortable_by_keys clicksCount: :clicks_count,
    resultsCount: :results_count,
    term: :query
end
