class AddAvgPositionToAd < ActiveRecord::Migration
  def change
    add_column :ads, :avg_position, :decimal, scale: 8, precision: 16, default: 0.0
  end
end
