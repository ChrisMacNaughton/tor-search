# encoding: utf-8
class AdsController < ApplicationController
  include Base::Behaviors::Angular
  before_filter :authenticate_advertiser!, except: [:advertising]
  before_filter :track

  # layout :choose_layout

  def index
    respond_to do |format|
      format.html{
        render :index
      }
    end
  end

  def new
    if current_advertiser.wants_js?
      respond_to do |format|
        format.html {
          render :index
        }
      end
    else
      @ad = Ad.new(advertiser: current_advertiser)
    end
  end

  def show
    if current_advertiser.wants_js?
      respond_to do |format|
        format.html {
          render :index
        }
      end
    else
      redirect_to :edit_ad
    end
  end

  def edit
    if current_advertiser.wants_js?
      respond_to do |format|
        format.html {
          render :index
        }
      end
    else
      @ad = Ad.find(params[:id])
    end
  end

  def create
    if current_advertiser.wants_js?
      respond_to do |format|
        format.html {
          render :index
        }
      end
    else
      @ad = Ad.new(params[:ad])
      @ad.advertiser = current_advertiser
      if @ad.save
        flash.notice = 'Your new ad has been successfully created'
        redirect_to ads_path
      else
        render :new
      end
    end
  end

  def update
    if current_advertiser.wants_js?
      respond_to do |format|
        format.html {
          render :index
        }
      end
    else
      @ad = Ad.find(params[:id])
      ad_attributes = params[:ad]
      keywords = params[:keywords]
      if ad_attributes.nil?
        render :new if keywords.nil?

        keywords = keywords.map(&:last)
        keywords.delete_if { |k| k[:keyword].empty? && k[:bid].empty? }

        keywords.each do |k|
          ad_keyword = AdKeyword.find_or_initialize_by_ad_id_and_keyword_id(@ad.id, Keyword.find_or_create_by_word(k[:keyword]).id)
          ad_keyword.bid =  k[:bid]
          ad_keyword.save
          @ad.ad_keywords << ad_keyword
        end
        redirect_to edit_ad_path(@ad)
      else
        ad_attributes[:approved] = false if @ad.changes.empty?
        if @ad.update_attributes(ad_attributes)
          flash.notice = 'Your ad has been successfully edited!'
          redirect_to ads_path
        else
          render :new
        end
      end
    end
  end

  def payment_addresses
    if current_advertiser.wants_js?
      respond_to do |format|
        format.html {
          render :index
        }
      end
    else
      get_payment_address
    end
  end

  def get_payment_address
    address = current_advertiser.bitcoin_addresses.order('created_at desc').first

    if address.nil? || address.created_at < 6.hours.ago
      coinbase = Coinbase::Client.new(TorSearch::Application.config.tor_search.coinbase_key)
      options = {
        address: {
          callback_url: 'http://ts.chrismacnaughton.com/payments'
        }
      }
      address = coinbase.generate_receive_address(options)
      @address = BitcoinAddress.new(address: address.address)
      @address.advertiser = current_advertiser
      @address.save
    else
      @address = address
    end
    @old_addresses = current_advertiser.bitcoin_addresses
  end

  def advertising # expressing interest page
    render 'ads/interested'
  end

  def toggle
    ad = Ad.find(params[:id])
    ad.disabled = !ad.disabled
    if ad.save
      flash.notice = 'Ad Toggled'
    else
      flash.error = 'There was a problem, try again soon!'
    end
    redirect_to :ads
  end

  def request_beta
    advertiser = Advertiser.find(params[:id])
    advertiser.wants_beta = true
    if advertiser.save
      flash.notice = 'Beta access requested'
    else
      flash.error 'There was a problem, try again soon!'
    end
    redirect_to :back
  end

  def partials
    render "ads/angular_partials/#{params[:partial]}", layout: false
  end

  private

  def track
    #return true unless Rails.env.include? 'production'
    return if params[:partial]

    Tracker.new(request).track_later!
  end

  def choose_layout
    if current_advertiser.wants_js?
      return 'ads'
    else
      return 'application'
    end
  end

  def _process_options options
    options[:template] = 'no_js/' + options[:template] unless current_advertiser.wants_js?
    super options
  end
end
