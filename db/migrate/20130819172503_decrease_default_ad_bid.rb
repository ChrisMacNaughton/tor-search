class DecreaseDefaultAdBid < ActiveRecord::Migration
  def up
    change_column :ads, :bid, :decimal, scale: 8, precision: 10, default: 0.001
    change_column :advertisers, :balance, :decimal, scale: 8, precision: 10, default: 0.000
  end

  def down
    change_column :ads, :bid, :decimal, scale: 2, precision: 10, default: 0.01
    change_column :advertisers, :balance, :decimal, scale: 2, precision: 10, default: 0.001
  end
end
