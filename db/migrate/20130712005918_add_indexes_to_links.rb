class AddIndexesToLinks < ActiveRecord::Migration
  def change
    add_index :links, :from_page_id
    add_index :links, :to_page_id
  end
end
