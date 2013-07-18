class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :path
      t.string :thumbnail_path
      t.references :domain

      t.timestamps
    end
  end
end
