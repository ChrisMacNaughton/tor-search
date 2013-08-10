class Query < ActiveRecord::Base
  attr_accessible :term

  has_many :searches

  def self.most_popular(scope, limit=5)
    searches = Search.send(scope)

    popular = Hash.new(0)
    searches.map{|s|  popular[s.query.term] += 1}

    popular.delete_if{|k,v| k.nil? || k.empty? }.sort_by{|search, count| -count}.first(5)
  end

end
