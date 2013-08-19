class CreateAds < ActiveRecord::Migration
  def change
    create_table :ads do |t|
      t.references :advertiser
      t.string :title
      t.string :path
      t.text :body
      t.boolean :disabled
      t.decimal :bid, scale: 2, precision: 10

      t.timestamps
    end
    add_index :ads, :advertiser_id
  end
end
