# encoding: utf-8
# tied to Coinbase wallet
class BitcoinAddress < ActiveRecord::Base
  belongs_to :advertiser
  attr_accessible :address
  has_many :payments
  def to_s
    address
  end

  def create_payment!(param)
    Payment.create(
      transaction_hash: param[:transaction][:hash],
      bitcoin_address: self,
      advertiser: advertiser,
      amount: param[:amount]
    )
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

  def self.validate_payment(coinbase_id, amount)
    begin
      res = Net::HTTP.get(URI "https://coinbase.com/api/v1/transactions/#{coinbase_id}?api_key=#{TorSearch::Application.config.tor_search.coinbase_key}")
      transaction = JSON.parse(res)
      amount == transaction['transaction']['amount']['amount'].to_f
    rescue => e
      Airbrake.notify(e)
      false
    end
  end
end
