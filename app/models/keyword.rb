# encoding: utf-8
# a keyword that can match a search
class Keyword < ActiveRecord::Base
  attr_accessible :word, :searches_counts, :status_id

  STATUS_IDS = [0,1,2]
  STATUS_NEGATIVE = 0
  STATUS_STATIC = 1
  STATUS_POSITIVE = 2

  after_create :setup_keyword_counts

  def setup_keyword_counts
    Delayed::Job.enqueue KeywordSupport::KeywordCountJob.new(self.id)
  end

  def update_keyword_counts!
    search_count_1 = Search \
      .joins(:query) \
      .where(created_at: 30.days.ago.beginning_of_day..15.days.ago.end_of_day) \
      .where('lower(term) like ?', "%#{word}%") \
      .count
    search_count_2 = Search \
      .joins(:query) \
      .where(created_at: 14.days.ago.beginning_of_day..Time.now.to_date.end_of_day) \
      .where('lower(term) like ?', "%#{word}%") \
      .count
    self.searches_counts = (search_count_1 + search_count_2) || 0
    growth = search_count_1 - search_count_2
    self.status_id = if growth > 0
      0
    elsif growth == 0
      1
    else
      2
    end
    save!
  end
end
