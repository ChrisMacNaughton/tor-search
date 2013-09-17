class AddCounterCacheToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :clicks_count, :integer, default: 0
    Search.find_each do |search|
      Search.reset_counters(search.id, :clicks)
    end
  end
end
