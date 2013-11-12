# encoding: utf-8
class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    respond_to do |format|
      format.html{
        render :index
      }
    end
  end

  def show
    respond_to do |format|
      format.html{
        render :index
      }
    end
  end

  def create
    if params[:hash] && params[:transaction_hash] && params[:amount]
      new_bitcoin_payment && return
    else

    end
  end

  def partials
    render "payments/angular_partials/#{params[:partial]}", layout: false
  end

  def new_bitcoin_payment
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
