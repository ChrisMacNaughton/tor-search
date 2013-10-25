# encoding: utf-8
class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def index
    address = BitcoinAddress.find_by_address(params[:address])
    if Payment.where(transaction_hash: params[:hash]).empty?
      Payment.create(
        transaction_hash: params[:transaction][:hash],
        bitcoin_address: params[:address],
        advertiser: address.advertiser,
        amount: params[:amount]
      )
    end
    render json: { status: 'ok' }
  end
end
