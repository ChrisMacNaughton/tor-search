class AddCouponCodeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :coupon_id, :string, default: nil
  end
end
