class AddPpcToAds < ActiveRecord::Migration
  def change
    add_column :ads, :ppc, :boolean, default: false
  end
end
