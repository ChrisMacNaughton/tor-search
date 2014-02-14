# encoding: utf-8
class AdsController < ApplicationController
  before_filter :authenticate_advertiser!, except: [:advertising]
  before_filter :track
  before_filter :set_campaigns_up

  def index

    page = (params[:page] || 1).to_i
    per_page = (20).to_i
    @ads = current_advertiser.ads.page(page) \
      .per_page(per_page)

    if params[:campaign_id]
      @ads = @ads.joins(ad_group: :ad_campaign) \
        .where(ad_groups: {ad_campaign_id: params[:campaign_id]})
      @campaign = current_advertiser.ad_campaigns.where(id: params[:campaign_id]).first
    end

    if params[:ad_group_id]
      @ads = @ads.where(ad_group_id: params[:ad_group_id])
      @ad_group = current_advertiser.ad_groups.where(id: params[:ad_group_id]).first
    end
    @ads = @ads.order('approved desc').order('title asc').includes(:ad_group, :ad_campaign)
  end

  def new
    @mixpanel_tracker.track(current_advertiser.id, 'create ad page')
    @ad = Ad.new(advertiser: current_advertiser, title: 'Example Title', protocol_id: 0, path: 'www.example.com?rel=ts', display_path: 'www.example.com', line_1: 'this is an', line_2: 'example ad', bid: 0.0001)
    if params[:ad_group_id]
      ad_group = AdGroup.find(params[:ad_group_id])
      if ad_group.advertiser_id == current_advertiser.id
        @ad.ad_group_id = params[:ad_group_id]
      end
    end
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
    if current_advertiser.is_auto_approved?
      @ad.approved = true
    end
    if @ad.save
      @mixpanel_tracker.track(current_advertiser.id, 'created an ad',  {ad: {id: @ad.id, title: @ad.title}}, visitor_ip_address)
      flash.notice = 'Your new ad has been successfully created'
      redirect_to ads_path
    else
      @mixpanel_tracker.track(current_advertiser.id, 'error creating ad', {error: @ad.errors}, visitor_ip_address)
      render :new
    end
  end

  def update
    @ad = Ad.find(params[:id])
    ad_attributes = params[:ad]
    keywords = params[:keywords]
    if ad_attributes.nil?
      render :new if keywords.nil?

      keywords = keywords.map(&:last)
      keywords.delete_if { |k| k[:keyword].empty? && k[:bid].empty? }

      keywords.each do |k|
        ad_keyword = AdKeyword.find_or_initialize_by_ad_id_and_keyword_id(@ad.id, Keyword.find_or_create_by_word(k[:keyword]).id)
        ad_keyword.bid =  k[:bid] || @ad.bid
        ad_keyword.save
        @ad.ad_keywords << ad_keyword
      end
      redirect_to edit_ad_path(@ad)
    else
      require_approval = [:title, :path, :display_path, :line_1, :line_2]
      approved = ad_attributes.select{ |k,v| require_approval.include? k.to_sym}.select{|k,v| @ad.send(k.to_sym) != v }.empty?
      ad_attributes[:approved] = false unless approved || current_advertiser.is_auto_approved?
      if @ad.update_attributes(ad_attributes)
        @mixpanel_tracker.track(current_advertiser.id, 'updated ad', {ad: {id: @ad.id, title: @ad.title}}, visitor_ip_address)
        flash.notice = 'Your ad has been successfully edited'
        flash.notice += ' and will be approved soon' if @ad.approved = false
        flash.notice += '!'
        redirect_to ads_path
      else
        @mixpanel_tracker.track(current_advertiser.id, 'error editing ad', {error: @ad.errors}, visitor_ip_address)
        render :edit
      end
    end
  end

  def payment_addresses
    #get_payment_address
    @addresses = current_advertiser.bitcoin_addresses.includes(:payments)
    @mixpanel_tracker.track(current_advertiser.id, 'view bitcoin address', {}, visitor_ip_address)
    render :get_payment_address
  end

  def get_payment_address
    address = current_advertiser.bitcoin_addresses.order('created_at desc').first
    @mixpanel_tracker.track(current_advertiser.id, 'requested bitcoin address', {}, visitor_ip_address)
    if address.nil? || address.created_at < 1.hour.ago
      coinbase = Coinbase::Client.new(TorSearch::Application.config.tor_search.coinbase_key)
      options = {
        address: {
          callback_url: 'https://torsearch.es/payments'
        }
      }
      address = coinbase.generate_receive_address(options)
      @address = BitcoinAddress.new(address: address.address)
      @address.advertiser = current_advertiser
      @address.save

      flash.notice = "Created a new address for you!"
    else
      flash.alert = "You've already created an address in the last hour"
      @address = address
    end
    redirect_to :btc_address
  end

  def advertising # expressing interest page
    render 'ads/interested', layout: 'application'
  end

  def toggle
    ad = Ad.find(params[:id] || params[:ad_id])
    ad.disabled = !ad.disabled
    if ad.save
      @mixpanel_tracker.track(current_advertiser.id, 'toggled an ad', {ad: {id: ad.id, title: ad.title}}, visitor_ip_address)
      flash.notice = 'Ad Toggled'
    else
      flash.alert = 'There was a problem, try again soon!'
    end
    redirect_to :back
  end

  def request_beta
    @mixpanel_tracker.track(current_advertiser.id, 'requested beta access', {}, visitor_ip_address)
    advertiser = current_advertiser
    advertiser.wants_beta = true
    if advertiser.save
      flash.notice = 'Beta access requested'
    else
      flash.alert 'There was a problem, try again soon!'
    end
    redirect_to :back
  end

  private

  def track
    #return true unless Rails.env.include? 'production'

    Tracker.new(request).track_later!
  end

   def set_campaigns_up
    unless current_advertiser.nil?
      @advertiser_campaigns = current_advertiser.ad_campaigns.order(:name)
      @advertiser_ad_groups = current_advertiser.ad_groups.order(:name).group_by(&:ad_campaign_id)
    end
  end
end
