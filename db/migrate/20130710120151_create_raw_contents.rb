class CreateRawContents < ActiveRecord::Migration
  def change
    create_table :raw_contents do |t|
      t.references :page
      t.text :body

      t.timestamps
    end
    add_index :raw_contents, :page_id
  end
end
