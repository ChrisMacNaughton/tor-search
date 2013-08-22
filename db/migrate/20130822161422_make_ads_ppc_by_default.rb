class MakeAdsPpcByDefault < ActiveRecord::Migration
  def up
    change_column :ads, :ppc, :boolean, default: true
  end

  def down
    change_column :ads, :ppc, :boolean, default: false
  end
end
