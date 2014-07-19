# encoding: utf-8

# a payment via coupon or bitcoin address
class Payment < ActiveRecord::Base
  belongs_to :advertiser
  belongs_to :bitcoin_address
  belongs_to :coupon

  belongs_to :parent, class_name: 'Payment', foreign_key: 'parent_id'
  attr_accessible :amount, :bitcoin_address, :advertiser, :advertiser_id,
                  :coupon, :transaction_hash, :parent, :parent_id

  after_create :credit_advertiser
  validates :coupon_id, uniqueness: {
    scope: [:advertiser_id, :bitcoin_address_id, :transaction_hash]
  }, unless: :is_bonus?
  validates :transaction_hash, uniqueness: {
    scope: [:advertiser_id, :coupon_id, :bitcoin_address_id]
  }, unless: :is_bonus?

  def credit_advertiser
    balance = advertiser.balance
    balance += amount
    logger.info {"Crediting #{advertiser} with #{amount}"}
    advertiser.update_attribute(:balance, balance)
  end

  def is_bonus?
    parent_id.present? || parent.present? || (bitcoin_address_id.nil? && coupon_id.nil?)
  end

end
