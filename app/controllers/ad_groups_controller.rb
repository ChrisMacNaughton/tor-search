# encoding: utf-8
class AdGroupsController < AdsCommonController

  def index
    page = (params[:page] || 1).to_i
    per_page = 15
    @ad_groups = current_advertiser.ad_groups \
      .page(page).per_page(per_page)

    if params[:campaign_id]
      @campaign = current_advertiser.ad_campaigns.where(id: params[:campaign_id]).first
      @ad_groups = @ad_groups.where(ad_campaign_id: params[:campaign_id])
    end

    @ad_groups = @ad_groups.order(:name, :created_at)
  end

  def show
    @show_deleted = false
    @ad_group = current_advertiser.ad_groups.where(id: params[:id]).first
    @campaign = @ad_group.ad_campaign

    @ads = @ad_group.ads.order('approved desc').order(:title, :created_at)
    if params[:show_deleted] == 'true'
      @show_deleted = true
      @ads = @ads.with_deleted
    end
  end

  def new
    redirect_to new_campaign_path and return if current_advertiser.ad_campaigns.empty?
    @ad_group = AdGroup.new
    @ad_group.ad_campaign_id = params[:campaign_id] if params[:campaign_id]

    @ad = Ad.new(advertiser: current_advertiser, title: 'Example Title', protocol_id: 0, path: 'www.example.com?rel=ts', display_path: 'www.example.com', line_1: 'this is an', line_2: 'example ad', bid: 0.0001)
  end

  def create
    @ad_group = AdGroup.new(params[:ad_group])
    @ad_group.advertiser_id = current_advertiser.id
    @ad_group.name ||= "Default Campaign"
    if @ad_group.save
      @ad = Ad.new(params[:ad])
      @ad.ad_group_id = @ad_group.id
      @ad.advertiser_id = current_advertiser.id
      if @ad.save
        redirect_to ad_group_keywords_path(@ad_group)
      else
        render "new"
      end
    else
      render "new"
    end
  end

  def toggle
    model_name = current_advertiser.ad_groups.where(id: params[:id] || params[:ad_group_id]).first
    if model_name.nil?
      flash.alert << 'There was a problem, try again soon (2)!'
      redirect_to :back and return
    end
    model_name.paused = !model_name.paused
    if model_name.save
      @mixpanel_tracker.track(current_advertiser.id, 'toggled an Ad Group', {model: {id: model_name.id}}, visitor_ip_address)
      flash.notice << 'Ad Group Toggled'
    else
      Rails.logger.info { model_name.errors }
      flash.alert << 'There was a problem, try again soon!'
    end
    redirect_to :back
  end

end