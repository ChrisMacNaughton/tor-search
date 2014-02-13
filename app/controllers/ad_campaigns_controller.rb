# encoding: utf-8
class AdCampaignsController < ApplicationController
  layout 'ads'
  before_filter :authenticate_advertiser!
  before_filter :set_campaigns_up

  def index
    @campaigns = @advertiser_campaigns
  end

  def ad_groups
    @campaign = AdCampaign.find(params[:id]) if params[:id]
    render :error_404 unless @campaign.advertiser == current_advertiser
    @ad_groups = current_advertiser.ad_groups
    if @campaign
      @ad_groups = @ad_groups.where(ad_campaign_id: @campaign.id)
    end
  end

  def show
    @campaign = AdCampaign.find(params[:id])
  end

  def new
    @campaign = AdCampaign.new
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

  def set_campaigns_up
    @advertiser_campaigns = current_advertiser.ad_campaigns
    @advertiser_ad_groups = current_advertiser.ad_groups.group_by(&:ad_campaign_id)
  end
end