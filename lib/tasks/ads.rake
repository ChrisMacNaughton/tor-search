namespace :ads do

  desc 'Update cached ad stats'
  task :update_ad_stats => :environment do
    AdGroup.where('updated_at < ?', 30.minutes.ago).find_in_batches(batch_size: 200) do |group|
      group.each do |ad_group|
        ad_group.refresh_counts!
      end
    end

    AdGroupKeyword.connection.execute(
      <<-SQL
      UPDATE ad_group_keywords
      SET clicks = (
        SELECT click_data.click_count
        FROM (
          SELECT count(keyword_id) as click_count, keyword_id
          FROM ad_clicks
          GROUP BY keyword_id
        ) as click_data
        WHERE click_data.keyword_id = ad_group_keywords.keyword_id
      )
      SQL
    )

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