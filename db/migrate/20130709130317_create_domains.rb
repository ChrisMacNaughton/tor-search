class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :path
      t.datetime :last_crawled
      t.decimal :domain_rank
      t.boolean :will_index

      t.timestamps
    end
  end
end
