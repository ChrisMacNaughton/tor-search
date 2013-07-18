class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.text :path
      t.references :domain

      t.timestamps
    end
  end
end
