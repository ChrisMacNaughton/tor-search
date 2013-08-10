class QuerySerializer < ActiveModel::Serializer
  attributes :created_at, :id, :term, :searches, :searches_count

  def searches
    object.searches.order('created_at desc')
  end
end
