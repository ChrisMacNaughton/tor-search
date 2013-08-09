class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :name
      t.text :text
      t.text :contact_method
      t.boolean :advertising

      t.timestamps
    end
  end
end
