class AddJsFlagToAdvertiser < ActiveRecord::Migration
  def change
    add_column :advertisers, :wants_js, :boolean, default: true
  end
end
