namespace :ads do

  desc 'Update cached ad stats'
  task :update_ad_stats => :environment do
    Rails.logger.info {"Refreshing Ad Group Stats"}
    AdGroup.where('updated_at < ?', 30.minutes.ago).find_in_batches(batch_size: 200) do |group|
      group.each do |ad_group|
        ad_group.refresh_counts!
      end
    end
    Rails.logger.info {"Refreshing Ad Group Keyword Stats"}
    AdGroupKeyword.refresh_counts!
    Rails.logger.info {"Refreshing Ad Stats"}
    Ad.refresh_counts!
  end
end