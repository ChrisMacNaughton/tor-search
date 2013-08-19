class AdSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :path, :approved

  has_one :advertiser

end
