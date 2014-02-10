class AddAdGroupToAds < ActiveRecord::Migration
  def change
    add_column :ads, :ad_group_id, :integer

    add_index :ads, :ad_group_id

    Ad.all.each do |ad|
      ad.update_attribute(:ad_group_id, AdGroup.where(advertiser_id: ad.advertiser_id).pluck(:id).first)
    end
  end
end
