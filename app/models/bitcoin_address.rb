# encoding: utf-8
# tied to Coinbase wallet
class BitcoinAddress < ActiveRecord::Base
  belongs_to :advertiser
  attr_accessible :address
  has_many :payments
  def to_s
    address
  end

  def self.generate_new_address(advertiser)
    coinbase = Coinbase::Client.new(TorSearch::Application.config.tor_search.coinbase_key)
    options = {
      address: {
        callback_url: 'https://torsearch.es/payments'
      }
    }
    address = coinbase.generate_receive_address(options)
    address = BitcoinAddress.new(address: address.address)
    address.advertiser = advertiser
    address.save

    address
  end
end
