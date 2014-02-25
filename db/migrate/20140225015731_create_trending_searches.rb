class CreateTrendingSearches < ActiveRecord::Migration
  def change
    create_table :trending_searches do |t|
      t.references :query
      t.integer :volume

      t.timestamps
    end
    add_index :trending_searches, :query_id
  end
end
