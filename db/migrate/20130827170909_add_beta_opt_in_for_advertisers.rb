class AddBetaOptInForAdvertisers < ActiveRecord::Migration
  def change
    add_column :advertisers, :beta, :boolean
  end
end
