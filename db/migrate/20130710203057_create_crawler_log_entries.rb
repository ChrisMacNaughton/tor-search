class CreateCrawlerLogEntries < ActiveRecord::Migration
  def change
    create_table :crawler_log_entries do |t|
      t.string :type_str
      t.string :action
      t.string :reason
      t.references :page

      t.timestamps
    end
  end
end
