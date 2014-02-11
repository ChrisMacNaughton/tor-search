# encoding: utf-8
class AdCampaignsController < ApplicationController
  layout 'ads'
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

  def set_campaigns_up
    @advertiser_campaigns = current_advertiser.ad_campaigns
    @advertiser_ad_groups = current_advertiser.ad_groups.group_by(&:ad_campaign_id)
  end
end