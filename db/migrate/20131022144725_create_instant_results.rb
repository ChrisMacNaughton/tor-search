class CreateInstantResults < ActiveRecord::Migration
  def change
    create_table :instant_results do |t|
      t.references :query
      t.string :bang_match

      t.timestamps
    end
  end
end
