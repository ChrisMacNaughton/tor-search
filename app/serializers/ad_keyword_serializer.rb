class AdKeywordSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :word, :bid, :keyword_id, :ad_title, :ad_id

  def ad_title
    object.ad.title
  end

end
