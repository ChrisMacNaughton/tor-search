class MakeApprovedFalseByDefaultOnAds < ActiveRecord::Migration
  def up
    change_column :ads, :approved, :boolean, default: false
    change_column :ads, :disabled, :boolean, default: false
  end

  def down
    change_column :ads, :approved, :boolean, default: true
    change_column :ads, :disabled, :boolean, default: true
  end
end
