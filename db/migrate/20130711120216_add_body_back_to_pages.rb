class AddBodyBackToPages < ActiveRecord::Migration
  def up
    add_column :pages, :body, :text
    execute "UPDATE pages SET body = (SELECT body FROM raw_contents WHERE page_id = pages.id)"
    drop_table :raw_contents
  end
  def down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
