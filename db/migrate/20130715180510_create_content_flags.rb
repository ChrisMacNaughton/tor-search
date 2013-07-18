class CreateContentFlags < ActiveRecord::Migration
  def change
    create_table :content_flags do |t|
      t.text :reason
      t.string :content_type
      t.integer :content_id

      t.timestamps
    end
  end
end
