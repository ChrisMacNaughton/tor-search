class AddCounterCacheOnAdClicks < ActiveRecord::Migration
  def up
    add_column :ads, :ad_clicks_count, :integer, default: 0

    execute "update ads set ad_clicks_count = (select count(*) from ad_clicks where ad_id = ads.id)"

  end

  def down
    remove_column :ads, :ad_clicks_count
  end
end
