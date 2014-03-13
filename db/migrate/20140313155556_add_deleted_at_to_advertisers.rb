class AddDeletedAtToAdvertisers < ActiveRecord::Migration
  def change
    add_column :advertisers, :deleted_at, :datetime
  end
end
