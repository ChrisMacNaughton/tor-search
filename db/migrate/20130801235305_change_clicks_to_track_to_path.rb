class ChangeClicksToTrackToPath < ActiveRecord::Migration
  def up
    add_column :clicks, :target, :text, default: ''
    execute "update clicks set target = subquery.target FROM (SELECT pages.id AS id, domains.path || '/' || pages.path  as target from pages inner join domains on pages.domain_id = domains.id) as subquery WHERE clicks.page_id = subquery.id;"
    remove_column :clicks, :page_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
