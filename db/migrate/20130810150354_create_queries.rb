class CreateQueries < ActiveRecord::Migration
  def up
    create_table :queries do |t|
      t.text :term
      t.integer :searches_count, default: 0

      t.timestamps
    end
    add_column :searches, :query_id, :integer
    Search.select("distinct on (query) *").pluck(:term).each do |t|
      Query.create!(term: t)
    end
    execute "update searches set query_id = (select id from queries where queries.term = searches.term limit 1)"

    Query.pluck(:id).each do |p_id|
      Query.reset_counters p_id, :searches
    end
    remove_column :searches, :term
  end
  def down
    add_column :searches, :term, :string
    Search.all.each do |search|
      term = Query.where(id: search.query_id).pluck(:term)[0]
      search.update_attribute(:term, term)
    end
    drop_table :queries
    remove_column :searches, :query_id
  end
end
