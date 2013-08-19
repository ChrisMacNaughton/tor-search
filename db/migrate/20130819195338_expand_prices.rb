class ExpandPrices < ActiveRecord::Migration
  def up
    change_column :ads, :bid, :decimal, scale: 8, precision: 16, default: 0.001
    change_column :advertisers, :balance, :decimal, scale: 8, precision: 16, default: 0.000
    change_column :ad_clicks, :bid, :decimal, scale: 8, precision: 16, default: 0.001
  end

  def down
    change_column :ads, :bid, :decimal, scale: 8, precision: 10, default: 0.001
    change_column :advertisers, :balance, :decimal, scale: 8, precision: 10, default: 0.000
    change_column :ad_clicks, :bid, :decimal, scale: 8, precision: 10, default: 0.001
  end
end
