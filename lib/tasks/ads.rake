namespace :ads do

  desc 'Update cached ad stats'
  task :update_ad_stats => :environment do
    AdGroup.where('updated_at < ?', 30.minutes.ago).find_in_batches(batch_size: 200) do |group|
      group.each do |ad_group|
        ad_group.refresh_counts!
      end
    end
    AdGroupKeyword.where('updated_at < ?', 30.minutes.ago).find_in_batches(batch_size: 200) do |group|
      group.each do |keyword|
        keyword.refresh_counts!
      end
    end
    Ad.where('updated_at < ?', 30.minutes.ago).find_in_batches(batch_size: 200) do |group|
      group.each do |ad|
        ad.refresh_counts!
      end
    end
  end
end