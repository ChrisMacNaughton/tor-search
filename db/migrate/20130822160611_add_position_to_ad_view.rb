class AddPositionToAdView < ActiveRecord::Migration
  def change
    add_column :ad_views, :position, :integer, default: nil
  end
end
