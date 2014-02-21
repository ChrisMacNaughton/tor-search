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
    Ad.connection.execute(
      <<-SQL
      UPDATE ads
      SET avg_position = (
        select averages.average
        from (
          select AVG(ad_views.position) as average, ad_views.ad_id
          from ad_views
          group by ad_id
        ) as averages
        where averages.ad_id = ads.id
      )
      SQL
    )
  end
end