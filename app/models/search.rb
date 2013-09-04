class Search < ActiveRecord::Base
  include SearchByKeyedScopes
  attr_accessible :query, :results_count, :paginated
  has_many :clicks
  belongs_to :query, counter_cache: true
  sortable_by_keys clicksCount: :clicks_count,
    resultsCount: :results_count,
    term: :query,
    created_at: :created_at
  scope :last_hour, -> { since(1.hour.ago.to_datetime) }
  scope :last_6_hours, -> { since(6.hours.ago.to_datetime) }
  scope :last_12_hours, -> { since(12.hours.ago.to_datetime) }
  scope :last_24_hours, -> { since(24.hours.ago.to_datetime) }
  scope :last_week, -> { since((7*24).hours.ago.to_datetime) }
  scope :last_month, -> { since(1.month.ago.to_date) }

  def self.within_range(from_date, to_date)
    where("searches.created_at BETWEEN ? AND ?", from_date, to_date)
  end

  # A helper for scopes, this method lets you find objects from between
  # a certain day and today.
  def self.since(date)
    within_range(date, DateTime.now.to_datetime)
  end
end
