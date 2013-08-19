class CreatePageviews < ActiveRecord::Migration
  def change
    create_table :pageviews do |t|
      t.boolean :search
      t.string :page

      t.timestamps
    end
  end
end
