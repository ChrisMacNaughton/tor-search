# encoding: utf-8

# a unique search query
class Query < ActiveRecord::Base
  attr_accessible :term

  has_many :searches
  validates :term, uniqueness: true

  EXCLUDED_WORDS = %w(porn pedo porno hard candy lolita cp)

  def self.trending
    res = ActiveRecord::Base.connection.execute trending_query
    trending = []
    res.each_row do |row|
      trending << {term: row[1], volume: row[0]}
    end
    trending
  end

  def self.trending_query
    <<-SQL
      WITH last_6_hour_query_counts AS (
        SELECT count(query_id) AS counts, query_id FROM searches WHERE created_at BETWEEN '#{6.hours.ago.to_s(:db)}' AND '#{0.hours.ago.to_s(:db)}' GROUP BY query_id
      ), last_12_hour_query_counts AS (
        SELECT count(query_id) AS counts, query_id FROM searches WHERE created_at BETWEEN '#{12.hours.ago.to_s(:db)}' AND '#{6.hours.ago.to_s(:db)}' GROUP BY query_id
      ), differences AS (
        select last_6_hour_query_counts.counts AS count_6_hour, last_12_hour_query_counts.counts AS count_12_hour, (COALESCE(last_6_hour_query_counts.counts, 0) - COALESCE(last_12_hour_query_counts.counts, 0)) AS difference, last_6_hour_query_counts.query_id AS query_id
        FROM last_6_hour_query_counts
        LEFT JOIN last_12_hour_query_counts ON last_12_hour_query_counts.query_id = last_6_hour_query_counts.query_id
      )
      SELECT count_6_hour, queries.term FROM differences LEFT JOIN queries ON differences.query_id = queries.id WHERE queries.term NOT IN ('#{EXCLUDED_WORDS.join("', '")}') ORDER BY difference desc LIMIT 5
    SQL
  end
end
