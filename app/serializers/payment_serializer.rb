class PaymentSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :bitcoin_address, :amount, :coupon_code

  def coupon_code
    object.coupon.try(:code)
  end

  def bitcoin_address
    object.bitcoin_address.try(:address)
  end
end
