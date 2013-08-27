class ChangeAdMinBid < ActiveRecord::Migration
  def up
    change_column :ads, :bid, :decimal, scale: 8, precision: 16, default: 0.005
    execute "update ads set bid = 0.005"
  end
  def down
    change_column :ads, :bid, :decimal, scale: 8, precision: 16, default: 0.0001
    execute "update ads set bid = 0.0001"
  end
end
