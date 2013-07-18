class AddUniquenessHashToObjects < ActiveRecord::Migration
  def change
    add_column :pages, :unique_hash, :string, default: ''
    add_column :pages, :duplicate_id, :integer

    add_column :images, :unique_hash, :string, default: ''
  end
end
