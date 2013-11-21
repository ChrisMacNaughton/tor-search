class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.references :query
      t.references :flag_reason
      t.text :path
      t.text :title

      t.timestamps
    end
    add_index :flags, :query_id
    add_index :flags, :flag_reason_id
  end
end
