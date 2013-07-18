class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :from_page_id
      t.integer :to_page_id
      t.text :anchor_text

      t.timestamps
    end
  end
end
