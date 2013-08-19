class AddUsernameToAdvertisers < ActiveRecord::Migration
  def change
    add_column :advertisers, :username, :string
  end
end
