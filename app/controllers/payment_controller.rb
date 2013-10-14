class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def index
    amount = params[:amount]
    address = params[:address]
    hash = params[:transaction][:hash]
    address = BitcoinAddress.find_by_address(address)
    if Payment.where(transaction_hash: hash).empty?
      payment = Payment.create(transaction_hash: hash, bitcoin_address: address, advertiser: address.advertiser, amount: amount)
    end
    render json: {status: 'ok'}
  end
end
