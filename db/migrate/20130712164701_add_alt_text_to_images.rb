class AddAltTextToImages < ActiveRecord::Migration
  def change
    add_column :images, :alt_text, :string, default: ""
  end
end
