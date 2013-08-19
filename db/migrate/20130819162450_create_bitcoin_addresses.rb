class CreateBitcoinAddresses < ActiveRecord::Migration
  def change
    create_table :bitcoin_addresses do |t|
      t.string :address
      t.references :advertiser

      t.timestamps
    end
    add_index :bitcoin_addresses, :advertiser_id
  end
end
