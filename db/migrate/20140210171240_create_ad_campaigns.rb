class CreateAdCampaigns < ActiveRecord::Migration
  def change
    create_table :ad_campaigns do |t|
      t.references :advertiser
      t.text :name
      t.boolean :paused, default: true
      t.timestamps
    end
    add_index :ad_campaigns, :advertiser_id
    Advertiser.all.each do |adv|
      AdCampaign.create(paused: false, name: 'Default Campaign', advertiser_id: adv.id)
    end
  end
end
