class AddIndexToQueryTerm < ActiveRecord::Migration
  def up
    execute("CREATE INDEX index_queries_on_term ON queries USING hash(term)")
  end

  def down
    execute("DROP INDEX index_queries_on_term")
  end
end
