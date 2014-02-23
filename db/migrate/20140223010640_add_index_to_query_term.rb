class AddIndexToQueryTerm < ActiveRecord::Migration
  def change
    add_index(:queries, :term)
  end
end
