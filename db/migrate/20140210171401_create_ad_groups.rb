class CreateAdGroups < ActiveRecord::Migration
  def up
    create_table :ad_groups do |t|
      t.references :ad_campaign
      t.references :advertiser
      t.boolean :paused, default: true
      t.text :name

      t.timestamps
    end
    add_index :ad_groups, :ad_campaign_id
    add_index :ad_groups, :advertiser_id

    add_column :ads, :ad_group_id, :integer
    add_index :ads, :ad_group_id

    Ad.all.unscoped.each do |ad|
      c = ad.advertiser.ad_campaigns.first
      ad_group = AdGroup.create(paused: false, ad_campaign_id: c.id, name: "#{ad.title} Ad Group", advertiser_id: ad.advertiser_id)
      ad.update_attribute(:ad_group_id, ad_group.id)
    end
  end
  def down
    drop_table :ad_groups
    remove_column :ads, :ad_group_id
  end
end
