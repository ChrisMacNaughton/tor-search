class CleanOutUnusedModels < ActiveRecord::Migration
  def up
    drop_table :flag_reasons
    drop_table :images
    drop_table :crawler_log_entries
    drop_table :content_flags
    drop_table :links
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
