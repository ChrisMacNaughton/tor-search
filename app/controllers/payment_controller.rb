class PaymentController < ApplicationController
  def index
    amount = params[:amount]
    address = params[:address]
    address = BitcoinAddress.find_by_address(address)
    payment = Payment.create(bitcoin_address: address, advertiser: address.advertiser, amount: amount)
    render json: {status: 'ok'}
  end
end
