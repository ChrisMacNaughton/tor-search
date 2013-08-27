class DropOldColumns < ActiveRecord::Migration
  def up
    remove_column :ads, :body
  end

  def down
  end
end
