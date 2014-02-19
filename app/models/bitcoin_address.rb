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
    begin
      res = Net::HTTP.get(URI "https://coinbase.com/api/v1/transactions/#{param[:transaction][:id]}?api_key=#{TorSearch::Application.config.tor_search.coinbase_key}")
      transaction = JSON.parse(res)['transaction']
    rescue => e
      Airbrake.notify(e)
      false
    end
    return false if transaction.nil?

    amount = transaction['amount']['amount'].to_f
    hash = transaction['hsh']
    payment = Payment.create(
      transaction_hash: hash,
      bitcoin_address: self,
      advertiser: advertiser,
      amount: amount
    )

    if DateTime.now.beginning_of_day > Date.parse('February 20th, 2014').beginning_of_day
      if DateTime.now.end_of_day < Date.parse('February 28th, 2014').end_of_day
        bonus_amount = if amount > 1.0
          amount * 0.15
        else
          amount * 0.10
        end
        Payment.create(
          advertiser: advertiser,
          amount: bonus_amount,
          parent_id: payment.id
        )
      end
    end
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
