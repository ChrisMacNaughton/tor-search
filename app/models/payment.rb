class Payment < ActiveRecord::Base
  belongs_to :advertiser
  belongs_to :bitcoin_address
  belongs_to :coupon
  attr_accessible :amount, :bitcoin_address, :advertiser

  after_create :credit_advertiser

  def credit_advertiser
    balance = advertiser.balance
    balance += amount
    logger.info "Crediting #{advertiser} with #{amount}"
    advertiser.update_attribute(:balance, balance)
  end
end
