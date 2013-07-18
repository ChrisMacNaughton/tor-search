class AddForeignKeysToModels < ActiveRecord::Migration

  def change
    add_index :pages, :path
    add_index :pages, [:path, :domain_id], unique: true
    add_index :images, :path
    add_index :images, [:path, :domain_id], unique: true
    add_index :documents, :path
    add_index :documents, [:path, :domain_id], unique: true
    add_index :domains, :path, unique: true

  end
end
