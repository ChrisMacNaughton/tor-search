class AddCouponCodeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :coupon_id, :integer, default: nil
  end
end
