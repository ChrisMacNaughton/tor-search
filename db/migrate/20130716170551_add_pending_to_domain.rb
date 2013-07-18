class AddPendingToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :pending, :boolean, default: false
  end
end
