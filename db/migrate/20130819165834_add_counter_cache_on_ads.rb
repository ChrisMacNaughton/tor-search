class AddCounterCacheOnAds < ActiveRecord::Migration
  def up
    add_column :ads, :ad_views_count, :integer, default: 0

    execute "update ads set ad_views_count = (select count(*) from ad_views where ad_id = ads.id)"

  end

  def down
    remove_column :ads, :ad_views_count
  end
end
