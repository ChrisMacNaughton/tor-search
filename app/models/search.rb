class Search < ActiveRecord::Base
  include SearchByKeyedScopes
  attr_accessible :query, :results_count
  has_many :clicks

  sortable_by_keys clicksCount: :clicks_count,
    resultsCount: :results_count,
    term: :query,
    created_at: :created_at
  scope :since, -> (time) {where('created_at >= ?', where)}
  scope :last_24_hours, since(24.hours.ago)
  scope :last_6_hours, where('created_at >= ?', 12.hours.ago)
end
