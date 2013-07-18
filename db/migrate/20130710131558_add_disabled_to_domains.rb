class AddDisabledToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :missed_attempts, :integer, default: 0
    add_column :domains, :blocked, :boolean, default: false
  end
end
