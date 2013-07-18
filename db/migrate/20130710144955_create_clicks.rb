class CreateClicks < ActiveRecord::Migration
  def change
    create_table :clicks do |t|
      t.references :search
      t.references :page

      t.timestamps
    end
    add_index :clicks, :search_id
    add_index :clicks, :page_id
  end
end
