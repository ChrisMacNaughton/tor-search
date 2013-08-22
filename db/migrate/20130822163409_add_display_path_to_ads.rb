class AddDisplayPathToAds < ActiveRecord::Migration
  def change
    add_column :ads, :display_path, :string, default: ""
  end
end
