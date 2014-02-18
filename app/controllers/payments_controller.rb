# encoding: utf-8
class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def new_bitcoin_payment
    address = BitcoinAddress.find_by_address(params[:address])
    if Payment.where(transaction_hash: params[:transaction][:hash]).empty?
      address.create_payment!(params)
    end
    render json: { status: 'ok' }
  end
end
