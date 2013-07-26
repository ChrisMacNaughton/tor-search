class Search < ActiveRecord::Base
  include SearchByKeyedScopes
  attr_accessible :query, :results_count
  has_many :clicks

  sortable_by_keys clicksCount: :clicks_count,
    resultsCount: :results_count,
    term: :query,
    created_at: :created_at
  scope :last_hour, -> { since(1.hour.ago.to_date) }
  scope :last_6_hours, -> { since(6.hours.ago.to_date) }
  scope :last_12_hours, -> { since(12.hours.ago.to_date) }
  scope :last_24_hours, -> { since(24.hours.ago.to_date) }
  scope :last_week, -> { since((7*24).hours.ago.to_date) }
  scope :last_month, -> { since(1.month.ago.to_date) }

  def self.most_popular(scope, limit=5)
    sql = "select count(query), query FROM \"searches\" WHERE searches.created_at BETWEEN '?' AND '?' GROUP BY query ORDER BY count(query) DESC LIMIT #{limit}"
    res = case scope
    when :last_hour
      Search.connection.execute(sql.sub('?', 1.hour.ago.to_s(:db)).sub('?', DateTime.now.to_s(:db)))
    when :last_6_hours
      Search.connection.execute(sql.sub('?', 6.hours.ago.to_s(:db)).sub('?', DateTime.now.to_s(:db)))
    when :last_12_hours
      Search.connection.execute(sql.sub('?', 12.hours.ago.to_s(:db)).sub('?', DateTime.now.to_s(:db)))
    when :last_24_hours
      Search.connection.execute(sql.sub('?', 24.hours.ago.to_s(:db)).sub('?', DateTime.now.to_s(:db)))
    when :last_week
      Search.connection.execute(sql.sub('?', (7*24).hours.ago.to_s(:db)).sub('?', DateTime.now.to_s(:db)))
    when :last_month
      Search.connection.execute(sql.sub('?', 1.month.ago.to_s(:db)).sub('?', DateTime.now.to_s(:db)))
    end
    popular = {}
    res.each_row{|v,k| popular[k] = v}
    popular
  end
  def self.within_range(from_date, to_date)
    where("searches.created_at BETWEEN ? AND ?", from_date, to_date)
  end

  # A helper for scopes, this method lets you find objects from between
  # a certain day and today.
  def self.since(date)
    within_range(date, DateTime.now)
  end
end
