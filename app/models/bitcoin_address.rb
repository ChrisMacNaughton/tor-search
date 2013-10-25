# encoding: utf-8
# tied to Coinbase wallet
class BitcoinAddress < ActiveRecord::Base
  belongs_to :advertiser
  attr_accessible :address
  has_many :payments
  def to_s
    address
  end
end
