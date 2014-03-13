class AddDeletedAtToOtherAdModels < ActiveRecord::Migration
  def change
    add_column :ad_groups, :deleted_at, :datetime
    add_column :ad_campaigns, :deleted_at, :datetime
  end
end
