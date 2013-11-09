# encoding: utf-8

# a payment via coupon or bitcoin address
class Payment < ActiveRecord::Base
  belongs_to :advertiser
  belongs_to :bitcoin_address
  belongs_to :coupon
  attr_accessible :amount, :bitcoin_address, :advertiser,
                  :coupon, :transaction_hash

  after_create :credit_advertiser
  validates :coupon_id, uniqueness: {
    scope: [:advertiser_id, :bitcoin_address_id]
  }
  validates :transaction_hash, uniqueness: {
    scope: [:advertiser_id, :coupon_id, :bitcoin_address_id]
  }
  def credit_advertiser
    balance = advertiser.balance
    balance += amount
    logger.info "Crediting #{advertiser} with #{amount}"
    advertiser.update_attribute(:balance, balance)
  end
end
