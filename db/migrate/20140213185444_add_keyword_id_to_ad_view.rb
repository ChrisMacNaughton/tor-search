class AddKeywordIdToAdView < ActiveRecord::Migration
  def change
    add_column :ad_views, :keyword_id, :integer
  end
end
