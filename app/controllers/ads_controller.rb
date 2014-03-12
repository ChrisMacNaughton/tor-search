# encoding: utf-8
class AdsController < AdsCommonController
  before_filter :authenticate_advertiser!, except: [:advertising]

  def index
    @show_deleted = false
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
    if params[:show_deleted] == 'true'
      @show_deleted = true
      @ads = @ads.with_deleted
    end
    @ads = @ads.order('approved desc').order('title asc, created_at asc').includes(:ad_group, :ad_campaign)
  end

  def new
    redirect_to new_campaign_path and return if current_advertiser.ad_campaigns.empty?
    redirect_to new_ad_group_path and return if current_advertiser.ad_groups.empty?
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
      flash.notice << 'Your new ad has been successfully created'
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
        message = 'Your ad has been successfully edited'
        message += ' and will be approved soon' if @ad.approved = false
        message += '!'
        flash.notice << message
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
      @address = BitcoinAddress.generate_new_address(current_advertiser)
      flash.notice << "Created a new address for you!"
    else
      flash.alert << "You can only create a new address once an hour"
      @address = address
    end
    redirect_to :billing
  end

  def advertising # expressing interest page
    @header_path = root_path
    notify_about_promotions(true)
    render 'ads/interested', layout: 'application'
  end

  def toggle
    ad = Ad.find(params[:id] || params[:ad_id])
    ad.disabled = !ad.disabled
    if ad.save
      @mixpanel_tracker.track(current_advertiser.id, 'toggled an ad', {ad: {id: ad.id, title: ad.title}}, visitor_ip_address)
      flash.notice << 'Ad Toggled'
    else
      flash.alert << 'There was a problem, try again soon!'
    end
    redirect_to :back
  end

  def request_beta
    @mixpanel_tracker.track(current_advertiser.id, 'requested beta access', {}, visitor_ip_address)
    advertiser = current_advertiser
    advertiser.wants_beta = true
    if advertiser.save
      flash.notice << 'Beta access requested'
    else
      flash.alert << 'There was a problem, try again soon!'
    end
    redirect_to :back
  end

  def delete
    ad = current_advertiser.ads.where(id: params[:ad_id]).first
    if ad.destroy
      flash.alert << "Successfully hid your ad"
    else
      flash.alert << "Something went wrong, please try again later"
    end
    redirect_to :back
  end

  def restore
    ad = current_advertiser.ads.with_deleted.where(id: params[:ad_id]).first
    if ad.restore
      flash.notice << "Successfully unhid your ad"
    else
      flash.alert << "Something went wrong, please try again later"
    end
    redirect_to :back
  end
end
