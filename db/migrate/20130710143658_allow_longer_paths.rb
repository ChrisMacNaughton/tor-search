class AllowLongerPaths < ActiveRecord::Migration
  def up
    change_column :pages, :path, :text
  end

  def down
    change_column :pages, :path, :string
  end
end
