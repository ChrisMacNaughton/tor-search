class CreateAdClicks < ActiveRecord::Migration
  def change
    create_table :ad_clicks do |t|
      t.references :ad
      t.references :query
      t.decimal :bid, scale: 8, precision: 10, default: 0.001

      t.timestamps
    end
  end
end
