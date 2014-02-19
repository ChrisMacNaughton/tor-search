namespace :keywords do

  desc 'Update keyword search counts'
  task :update_search_counts => :environment do
    Keyword.where('updated_at < ?', 30.minutes.ago).find_in_batches(batch_size: 200) do |group|
      group.each do |keyword|
        search_count_1 = Search \
          .joins(:query) \
          .where(created_at: 30.days.ago.beginning_of_day..15.days.ago.end_of_day) \
          .where('lower(term) like ?', "%#{keyword.word}%") \
          .count
        search_count_2 = Search \
          .joins(:query) \
          .where(created_at: 14.days.ago.beginning_of_day..Time.now.to_date.end_of_day) \
          .where('lower(term) like ?', "%#{keyword.word}%") \
          .count
        keyword.searches_counts = (search_count_1 + search_count_2) || 0
        growth = search_count_1 - search_count_2
        keyword.status_id = if growth > 0
          0
        elsif growth == 0
          1
        else
          2
        end
        keyword.save
      end
    end
  end
end