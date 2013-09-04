class RemovePageviews < ActiveRecord::Migration
  def up
    drop_table :pageviews
  end

  def down
    create_table :pageviews do |t|
      t.boolean :search
      t.string :page

      t.timestamps
    end
  end
end
