# encoding: utf-8
class Api::PaymentController < ApplicationController
  include Base::Behaviors::Angular
  before_filter :authenticate_advertiser!
  before_filter :track

  def index
    respond_to do |format|
      format.json {
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 20).to_i

        render json: paginated_results_hash(current_advertiser.payments.page(page) \
          .per_page(per_page).order(:created_at), {serializer: PaymentSerializer})
      }
    end
  end

  def create
    respond_to do |format|
      format.json {
        coupon = Coupon.find_by_code(params[:payment][:coupon_code])

        if coupon.nil?
          result = {error: 'Invalid Coupon Code'}
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
            result = {value: coupon.value}
            @mixpanel_tracker.track(current_advertiser.id, 'applied a coupon', {value: coupon.value}, visitor_ip_address)
          else
            result = {error: "You've already redeemed this code"}
          end
        end
        render json: result
      }
    end
  end

  private

  def track
    #return true unless Rails.env.include? 'production'

    Tracker.new(request).track_later!
  end

end
