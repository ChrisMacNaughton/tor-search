# encoding: utf-8
class CouponController < ApplicationController
  before_filter :authenticate_advertiser!
  # rubocop:disable MethodLength
  def create
    coupon = Coupon.find_by_code(params[:coupon][:code])
    if coupon.nil?
      flash.alert = 'Coupon code is invalid'
    else
      p = Payment.where(
        coupon_id: coupon.id,
        advertiser_id: current_advertiser.id
      )
      if p.empty?
        Payment.create(
          advertiser: current_advertiser,
          coupon: coupon,
          amount: coupon.value
        )
        flash.notice = 'Your account has been credited'
        flash.notice += " #{coupon.value} BTC for the coupon"
      else
        flash.alert = 'You have already redeemed this coupon!'
      end
    end
    redirect_to :back
  end
  # rubocop:enable MethodLength
end
