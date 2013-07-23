class AddCounterCacheToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :clicks_count, :integer, default: 0
    Search.find_each do |search|
      Search.reset_counters(search.id, :clicks)
      #search.update_attribute(:clicks_count, search.clicks.length)
      #search.save
    end
  end
end
