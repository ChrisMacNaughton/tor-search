class AddSearchIdToAdClick < ActiveRecord::Migration
  def change
    add_column :ad_clicks, :search_id, :integer
  end
end
