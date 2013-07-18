class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :path
      t.references :domain, index: true
      t.string :title
      t.text :description
      t.text :meta_keywords
      t.text :meta_generator
      t.text :body
      t.datetime :last_crawled
      t.decimal :page_rank

      t.timestamps
    end
  end
end
