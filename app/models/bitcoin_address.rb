# encoding: utf-8
# tied to Coinbase wallet
class BitcoinAddress < ActiveRecord::Base
  belongs_to :advertiser
  attr_accessible :address
  has_many :payments
  def to_s
    address
  end

  def create_payment!(params)

    amount = params[:amount].to_f
    hash = params[:transaction][:hash]
    payment = Payment.create(
      transaction_hash: hash,
      bitcoin_address: self,
      advertiser: advertiser,
      amount: amount
    )

  end

  def self.generate_new_address(advertiser)
    coinbase = Coinbase::Client.new(TorSearch::Application.config.tor_search.coinbase_key, TorSearch::Application.config.tor_search.coinbase_secret)
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
