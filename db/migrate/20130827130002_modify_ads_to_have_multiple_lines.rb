class ModifyAdsToHaveMultipleLines < ActiveRecord::Migration
  def up
    execute 'UPDATE ads set title = substring(title from 01 FOR 25)'
    add_column :ads, :line_1, :string, default: "", limit: 35
    add_column :ads, :line_2, :string, default: "", limit: 35
    change_column :ads, :display_path, :string, default: "", limit: 35
    change_column :ads, :title, :string, default: "", limit: 25
    add_column :ads, :protocol_id, :integer, default: 0
    change_column :ads, :path, :text, default: "", limit: 2047
    Ad.all.each do |ad|
      desc = ad.body
      ad.line_1 = desc[0...35]
      ad.line_2 = desc[36...70]
      ad.protocol_id = 0
      ad.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
