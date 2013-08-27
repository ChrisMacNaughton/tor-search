class AddWantsBetaToAdvertiser < ActiveRecord::Migration
  def change
    add_column :advertisers, :wants_beta, :boolean
  end
end
