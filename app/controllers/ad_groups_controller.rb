# encoding: utf-8
class AdGroupsController < ApplicationController
  layout 'ads'
  before_filter :set_campaigns_up

  def index
    @ad_groups = current_advertiser.ad_groups

    if params[:campaign_id]
      @campaign = current_advertiser.ad_campaigns.where(id: params[:campaign_id]).first
      @ad_groups = @ad_groups.where(ad_campaign_id: params[:campaign_id])
    end
  end

  def show
    @ad_group = current_advertiser.ad_groups.where(id: params[:id]).first
    @campaign = @ad_group.ad_campaign

    @ads = @ad_group.ads
  end

  def set_campaigns_up
    @advertiser_campaigns = current_advertiser.ad_campaigns
    @advertiser_ad_groups = current_advertiser.ad_groups.group_by(&:ad_campaign_id)
  end
end