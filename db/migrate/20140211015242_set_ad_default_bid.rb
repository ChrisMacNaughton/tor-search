class SetAdDefaultBid < ActiveRecord::Migration
  def up
    change_column :ads, :bid, :decimal, scale: 8, precision: 16, default: 0.0
  end

  def down
    change_column :ads, :bid, :decimal, scale: 8, precision: 16, default: 0.005
  end
end
