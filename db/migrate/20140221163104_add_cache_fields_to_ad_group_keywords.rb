class AddCacheFieldsToAdGroupKeywords < ActiveRecord::Migration
  def change
    add_column :ad_group_keywords, :clicks, :integer, default: 0
    add_column :ad_group_keywords, :views, :integer, default: 0
  end
end
