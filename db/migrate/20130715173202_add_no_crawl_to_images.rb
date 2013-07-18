class AddNoCrawlToImages < ActiveRecord::Migration
  def change
    add_column :images, :no_crawl, :boolean, default: false
    add_column :images, :last_crawled, :datetime
  end
end
