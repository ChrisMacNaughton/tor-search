class AddDefaultBidToCampaign < ActiveRecord::Migration
  def change
    add_column :ad_campaigns, :default_bid, :decimal, scale: 8, precision: 16, default: 0.0
  end
end
