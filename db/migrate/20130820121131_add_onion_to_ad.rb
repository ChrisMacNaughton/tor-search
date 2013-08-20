class AddOnionToAd < ActiveRecord::Migration
  def change
    add_column :ads, :onion, :boolean, default: false
  end
end
