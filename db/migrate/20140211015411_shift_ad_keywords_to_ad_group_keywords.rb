class ShiftAdKeywordsToAdGroupKeywords < ActiveRecord::Migration
  def up
    create_table :ad_group_keywords do |t|
      t.references :ad_group
      t.references :keyword
      t.decimal :bid, scale: 8, precision: 16

      t.timestamps
    end
    add_index :ad_group_keywords, :ad_group_id
    add_index :ad_group_keywords, :keyword_id
    add_index :ad_group_keywords, [:ad_group_id, :keyword_id], unique: true
    AdKeyword.all.each do |k|
      AdGroupKeyword.create!(ad_group_id: k.ad.ad_group.id, keyword_id: k.keyword_id, bid: k.bid)
    end
    drop_table :ad_keywords
  end

  def down
    create_table :ad_keywords do |t|
      t.references :ad
      t.references :keyword
      t.decimal :bid, scale: 8, precision: 16, default: 0.0001

      t.timestamps
    end
    add_index :ad_keywords, :ad_id
    add_index :ad_keywords, :keyword_id

    AdGroupKeyword.all.each do |ak|
      AdKeyword.create(ad_id: ak.ads.first.id, keyword_id: ak.keyword_id, bid: ak.bid)
    end
    drop_table :ad_group_keywords
  end
end
