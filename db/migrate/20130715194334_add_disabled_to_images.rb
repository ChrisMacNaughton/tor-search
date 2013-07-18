class AddDisabledToImages < ActiveRecord::Migration
  def change
    add_column :images, :disabled, :boolean, default: false
  end
end
