class AddCacheFieldsToAdGroup < ActiveRecord::Migration
  def change
    add_column :ad_groups, :clicks_count, :integer, default: 0
    add_column :ad_groups, :views_count, :integer, default: 0
    add_column :ad_groups, :ctr, :decimal, scale: 8, precision: 16, default: 0.0
    add_column :ad_groups, :avg_position, :decimal, scale: 8, precision: 16, default: 0.0
  end
end
