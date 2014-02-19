class AddFieldsToKeyword < ActiveRecord::Migration
  def change
    add_column :keywords, :searches_counts, :integer, default: nil
    add_column :keywords, :status_id, :integer, default: 1
  end
end
