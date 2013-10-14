class AddTransactionHashToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :transaction_hash, :string
  end
end
