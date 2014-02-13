class AddPausedToAdGroupKeywords < ActiveRecord::Migration
  def change
    add_column :ad_group_keywords, :paused, :boolean, default: false
  end
end
