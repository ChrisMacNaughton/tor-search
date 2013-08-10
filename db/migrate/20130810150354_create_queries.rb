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

    execute "update queries set searches_count = (select count(*) from searches where query_id = queries.id)"

    remove_column :searches, :term
  end
  def down
    add_column :searches, :term, :string

    execute "update searches set term = (select term from queries where queries.id = searches.query_id)"

    drop_table :queries
    remove_column :searches, :query_id
  end
end
