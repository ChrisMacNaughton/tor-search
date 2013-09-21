class AddJavascriptEnabledToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :js_enabled, :boolean, default: false
  end
end
