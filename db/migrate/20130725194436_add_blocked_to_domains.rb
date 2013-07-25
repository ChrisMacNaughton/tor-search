class AddBlockedToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :disabled, :boolean, default: false
  end
end
