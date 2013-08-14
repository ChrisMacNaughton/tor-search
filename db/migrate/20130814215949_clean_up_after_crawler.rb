class CleanUpAfterCrawler < ActiveRecord::Migration
  def change
    drop_table :domains
    drop_table :pages
    create_table :domains do |t|
      t.string :path
      t.boolean :pending
      t.timestamps
    end
  end
end
