class AddParentIdToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :parent_id, :integer, default: nil
  end
end
