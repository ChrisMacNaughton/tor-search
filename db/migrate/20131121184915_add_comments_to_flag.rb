class AddCommentsToFlag < ActiveRecord::Migration
  def change
    add_column :flags, :comments, :text
  end
end
