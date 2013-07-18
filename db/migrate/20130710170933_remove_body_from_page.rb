class RemoveBodyFromPage < ActiveRecord::Migration
  def up
    remove_column :pages, :body
  end
end
