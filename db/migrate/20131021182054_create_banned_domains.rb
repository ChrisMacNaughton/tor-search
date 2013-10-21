class CreateBannedDomains < ActiveRecord::Migration
  def change
    create_table :banned_domains do |t|
      t.string :hostname, null: false, unique: true
      t.text :reason
      t.timestamps
    end
  end
end
