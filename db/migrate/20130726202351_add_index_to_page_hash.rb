class AddIndexToPageHash < ActiveRecord::Migration
  def change
    add_index :pages, :unique_hash
  end
end
