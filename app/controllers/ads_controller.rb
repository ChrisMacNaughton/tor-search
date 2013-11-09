# encoding: utf-8
class AdsController < ApplicationController
  include Base::Behaviors::Angular
  before_filter :authenticate_advertiser!, except: [:advertising]
  before_filter :track, except: [:partials]

  def index
    if current_advertiser.wants_js?
      respond_to do |format|
        format.html{
          render :index
        }
      end
    else
      page = (params[:page] || 1).to_i
      per_page = (params[:per_age] || 20).to_i
      @ads = current_advertiser.ads.page(page) \
        .per_page(per_page).order(:created_at)
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
        require_approval = [:title, :path, :display_path, :line_1, :line_2]
        approved = ad_attributes.select{ |k,v| require_approval.include? k.to_sym}.select{|k,v| @ad.send(k.to_sym) != v }.empty?
        ad_attributes[:approved] = false unless approved
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
      render :get_payment_address
    end
  end

  def get_payment_address
    address = current_advertiser.bitcoin_addresses.order('created_at desc').first

    if address.nil? || address.created_at < 6.hours.ago
      coinbase = Coinbase::Client.new(TorSearch::Application.config.tor_search.coinbase_key)
      options = {
        address: {
          callback_url: 'http://ts.chrismacnaughton.com:8080/payments'
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

    Tracker.new(request).track_later!
  end

  def _process_options options
    options[:template] = 'no_js/' + options[:template] unless current_advertiser.wants_js?
    super options
  end
end
