# encoding: utf-8
class AdCampaignsController < AdsCommonController

  def index
    page = (params[:page] || 1).to_i
    per_page = (10).to_i
    @campaigns = @advertiser_campaigns \
      .page(page).per_page(per_page).order(:name, :created_at)
  end

  def show
    @campaign = AdCampaign.find(params[:id])
  end

  def new
    @campaign = AdCampaign.new(default_bid: 0.0001)
  end

  def create
    @campaign = AdCampaign.new(params[:ad_campaign])
    @campaign.advertiser = current_advertiser
    if @campaign.save
      flash.notice = "Your campaign has been created successfully!"
      redirect_to new_ad_group_path({campaign_id: @campaign.id})
    else
      render 'new'
    end
  end

  def toggle
    model_name = current_advertiser.ad_campaigns.where(id: params[:id] || params[:campaign_id]).first
    if model_name.nil?
      flash.alert = 'There was a problem, try again soon!'
      redirect_to :back and return
    end
    model_name.paused = !model_name.paused
    if model_name.save
      @mixpanel_tracker.track(current_advertiser.id, 'toggled a Campaign', {keyword: {id: model_name.id}}, visitor_ip_address)
      flash.notice = 'Campaign Toggled'
    else
      flash.alert = 'There was a problem, try again soon!'
    end
    redirect_to :back
  end

end