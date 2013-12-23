# encoding: utf-8
class Api::BitcoinAddressController < ApplicationController
  include Base::Behaviors::Angular
  before_filter :authenticate_advertiser!
  #before_filter :track

  def index
    respond_to do |format|
      format.json {
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i
        render json: paginated_results_hash(current_advertiser.bitcoin_addresses.page(page) \
          .per_page(per_page).order('created_at desc'), {serializer: BitcoinAddressSerializer})
      }
    end
  end

  def create
    respond_to do |format|
      format.json {
        @mixpanel_tracker.track(current_advertiser.id, 'requested bitcoin address', visitor_ip_address)
        coinbase = Coinbase::Client.new(TorSearch::Application.config.tor_search.coinbase_key)
        options = {
          address: {
            callback_url: 'http://ts.chrismacnaughton.com/payments'
          }
        }
        address = coinbase.generate_receive_address(options)
        address = BitcoinAddress.new(address: address.address)
        address.advertiser = current_advertiser
        address.save

        render json: {records: [BitcoinAddressSerializer.new(address)]}
      }
    end
  end

  private

  def track
    #return true unless Rails.env.include? 'production'

    Tracker.new(request).track_later!
  end

end
