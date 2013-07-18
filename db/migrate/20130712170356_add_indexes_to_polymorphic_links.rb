class AddIndexesToPolymorphicLinks < ActiveRecord::Migration
  def change
    remove_index :links, :from_page_id
    remove_index :links, :to_page_id

    add_index :links, :from_target_id
    add_index :links, :to_target_id
  end
end
