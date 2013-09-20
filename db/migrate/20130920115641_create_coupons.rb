class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :code
      t.decimal :value, scale: 8, precision: 16, default: 0

      t.timestamps
    end
  end
end
