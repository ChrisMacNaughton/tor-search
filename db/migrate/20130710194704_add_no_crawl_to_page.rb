class AddNoCrawlToPage < ActiveRecord::Migration
  def change
    add_column :pages, :no_crawl, :boolean, default: false
  end
end
