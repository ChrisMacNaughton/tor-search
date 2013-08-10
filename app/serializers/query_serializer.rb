class QuerySerializer < ActiveModel::Serializer
  attributes :created_at, :id, :term, :searches, :search_count

  def searches
    object.searches.order('created_at desc')
  end
end
