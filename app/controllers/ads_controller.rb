class AdsController < ApplicationController
  before_filter :authenticate_advertiser!, except: [:advertising, :redirect]
  def index
    Pageview.create(search: false, page: "AdsIndex")
    page = (params[:page] || 1).to_i
    per_page = (params[:per_age] || 20).to_i
    @ads = current_advertiser.ads.page(page).per_page(per_page).order(:created_at)
  end
  def new
    Pageview.create(search: false, page: "AdsCreate")
    @ad = Ad.new
  end
  def create
    @ad = Ad.new(params[:ad])
    @ad.advertiser = current_advertiser
    if @ad.save
      flash.notice = "Your new ad has been successfully created"
      redirect_to ads_path
    else
      render :new
    end
  end
  def get_payment_address
    address = current_advertiser.bitcoin_addresses.order('created_at desc').first

    if address.present? && address.created_at < 6.hours.ago
      coinbase = Coinbase::Client.new(TorSearch::Application.config.tor_search.coinbase_key)
      options = {address: {callback_url: 'http://chrismacnaughton.com'}}
      address = coinbase.generate_receive_address(options)
      @address = BitcoinAddress.new(address: address.address)
      @address.advertiser = current_advertiser
      @address.save
    else
      @address = address
    end
    @old_addresses = current_advertiser.bitcoin_addresses
  end
  def advertising #expressing interest page
    Pageview.create(search: false, page: "AdsInterest")
    render 'ads/interested'
  end
  def toggle
    ad = Ad.find(params[:id])
    ad.disabled = !ad.disabled
    if ad.save
      flash.notice = "Ad Toggled"
    else
      flash.error = "There was a problem, try again soon!"
    end
    redirect_to :ads
  end
  def redirect
    debugger
    ad = Ad.find(params[:id])
    query = Query.find(params[:q])
    AdClick.create(ad: ad, query: query, bid: ad.bid)
    redirect_to ad.path
  end
end
