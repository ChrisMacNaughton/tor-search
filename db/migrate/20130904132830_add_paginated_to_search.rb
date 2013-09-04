class AddPaginatedToSearch < ActiveRecord::Migration
  def change
    add_column :searches, :paginated, :boolean, default: false
  end
end
