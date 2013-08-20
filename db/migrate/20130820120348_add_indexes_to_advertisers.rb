class AddIndexesToAdvertisers < ActiveRecord::Migration
  def up
    remove_index :advertisers, :email
    add_index :advertisers, :username, unique: true
  end
  def down
    remove_index :advertisers, :username
    add_index :advertisers, :email, unique: true
  end
end
