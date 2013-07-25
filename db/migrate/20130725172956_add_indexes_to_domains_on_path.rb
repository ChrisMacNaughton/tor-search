class AddIndexesToDomainsOnPath < ActiveRecord::Migration
  def change
    add_index :domains, :path
  end
end
