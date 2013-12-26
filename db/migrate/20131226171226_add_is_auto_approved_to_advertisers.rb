class AddIsAutoApprovedToAdvertisers < ActiveRecord::Migration
  def change
    add_column :advertisers, :is_auto_approved, :boolean, default: false
  end
end
