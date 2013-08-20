class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.decimal :amount, scale: 8, precision: 16, default: 0
      t.references :advertiser
      t.references :bitcoin_address

      t.timestamps
    end
    add_index :payments, :advertiser_id
    add_index :payments, :bitcoin_address_id
  end
end
