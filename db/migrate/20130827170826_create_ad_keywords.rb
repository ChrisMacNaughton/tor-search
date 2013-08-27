class CreateAdKeywords < ActiveRecord::Migration
  def change
    create_table :ad_keywords do |t|
      t.references :ad
      t.references :keyword
      t.decimal :bid, scale: 8, precision: 16, default: 0.0001

      t.timestamps
    end
    add_index :ad_keywords, :ad_id
    add_index :ad_keywords, :keyword_id
  end
end
