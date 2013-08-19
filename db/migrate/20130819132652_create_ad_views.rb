class CreateAdViews < ActiveRecord::Migration
  def change
    create_table :ad_views do |t|
      t.references :ad
      t.references :query

      t.timestamps
    end
    add_index :ad_views, :ad_id
    add_index :ad_views, :query_id
  end
end
