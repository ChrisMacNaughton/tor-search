class SearchSerializer < ActiveModel::Serializer
  attributes :created_at, :id, :term, :clicks_count, :results_count

  def term
    object.query.term
  end
end
