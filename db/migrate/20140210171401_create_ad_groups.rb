class CreateAdGroups < ActiveRecord::Migration
  def change
    create_table :ad_groups do |t|
      t.references :ad_campaign
      t.references :advertiser
      t.boolean :paused, default: true
      t.text :name

      t.timestamps
    end
    add_index :ad_groups, :ad_campaign_id
    add_index :ad_groups, :advertiser_id
    AdCampaign.all.each do |c|
      AdGroup.create(paused: false, ad_campaign_id: c.id, name: 'Default Ad Group', advertiser_id: c.advertiser_id)
    end
  end
end
