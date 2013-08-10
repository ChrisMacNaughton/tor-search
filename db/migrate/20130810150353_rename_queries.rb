class RenameQueries < ActiveRecord::Migration
  def change
    rename_column :searches, :query, :term
  end
end
