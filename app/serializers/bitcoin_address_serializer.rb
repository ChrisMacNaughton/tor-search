class BitcoinAddressSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :address, :balance

  def balance
    object.payments.sum(&:amount)
  end

end
