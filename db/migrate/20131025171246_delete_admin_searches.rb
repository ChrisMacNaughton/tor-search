class DeleteAdminSearches < ActiveRecord::Migration
  def up
    drop_table :admin_searches
  end

  def down
    create_table :admin_searches do |t|
      t.references :admin
      t.string :controller_class
      t.text :search_params
      t.text :sort_params
    end
  end
end
