class AdSerializer < ActiveModel::Serializer
  attributes :id, :title, :line_1, :line_2, :path, :approved

  has_one :advertiser

end
