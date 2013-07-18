class AddPolymorphismToLinks < ActiveRecord::Migration
  def change
    add_column :links, :from_target_type, :string, default: 'Page'
    add_column :links, :to_target_type, :string, default: 'Page'

    rename_column :links, :to_page_id, :to_target_id
    rename_column :links, :from_page_id, :from_target_id
  end
end
