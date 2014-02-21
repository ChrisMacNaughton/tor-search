namespace :ads do

  desc 'Update cached ad stats'
  task :update_ad_stats => :environment do
    Rails.logger.info {"Refreshing Ad Group Stats"}
    AdGroup.refresh_counts!
    Rails.logger.info {"Refreshing Ad Group Keyword Stats"}
    AdGroupKeyword.refresh_counts!
    Rails.logger.info {"Refreshing Ad Stats"}
    Ad.refresh_counts!
  end
end