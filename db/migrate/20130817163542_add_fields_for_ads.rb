class AddFieldsForAds < ActiveRecord::Migration
  def up
    add_column :ads, :approved, :boolean, default: true
    change_column :ads, :bid, :decimal, scale: 2, precision: 10, default: 0.01
    add_column :advertisers, :balance, :decimal, scale: 2, precision: 10, default: 0
  end

  def down
    remove_column :ads, :approved
    remove_column :advertisers, :balance
  end
end
