class AddHandlerHashToDelayedJob < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :handler_hash, :string
    add_index  :delayed_jobs, :handler_hash
  end
end
