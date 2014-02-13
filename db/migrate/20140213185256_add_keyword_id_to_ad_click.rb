class AddKeywordIdToAdClick < ActiveRecord::Migration
  def change
    add_column :ad_clicks, :keyword_id, :integer
  end
end
