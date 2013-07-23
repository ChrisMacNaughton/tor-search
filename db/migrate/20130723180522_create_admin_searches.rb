class CreateAdminSearches < ActiveRecord::Migration
  def change
    create_table :admin_searches do |t|
      t.references :admin
      t.string :controller_class
      t.text :search_params
      t.text :sort_params
    end
  end
end
