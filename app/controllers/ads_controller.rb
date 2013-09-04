class AdsController < ApplicationController
  before_filter :authenticate_advertiser!, except: [:advertising]
  def index
    page = (params[:page] || 1).to_i
    per_page = (params[:per_age] || 20).to_i
    @ads = current_advertiser.ads.page(page).per_page(per_page).order(:created_at)
  end
  def new
    #@ad = Ad.new
  end
  def show
    redirect_to :edit_ad
  end
  def edit
    @ad = Ad.find(params[:id])
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
  def update
    @ad = Ad.find(params[:id])
    ad_attributes = params[:ad]
    ad_attributes[:approved] = false if @ad.changes.empty?

    #keywords = params[:keywords].split(',')
    #keys = []
    #keywords.each do |kw|
    #  keys << Keyword.find_or_create_by_word(kw)
    #end
    if @ad.update_attributes(ad_attributes)
      flash.notice = "Your ad has been successfully edited!"
      redirect_to ads_path
    else
      render :new
    end
  end
  def get_payment_address
    address = current_advertiser.bitcoin_addresses.order('created_at desc').first

    if address.nil? || address.created_at < 6.hours.ago
      coinbase = Coinbase::Client.new(TorSearch::Application.config.tor_search.coinbase_key)
      options = {address: {callback_url: 'http://ts.chrismacnaughton.com/payments'}}
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
  def request_beta
    advertiser = Advertiser.find(params[:id])
    advertiser.wants_beta = true
    if advertiser.save
      flash.notice = "Beta access requested"
    else
      flash.error "There was a problem, try again soon!"
    end
    redirect_to :back
  end
end
