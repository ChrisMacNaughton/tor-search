class CreateFlagReasons < ActiveRecord::Migration
  def change
    create_table :flag_reasons do |t|
      t.string :description

      t.timestamps
    end
    add_column :content_flags, :flag_reason_id, :integer
  end
end
