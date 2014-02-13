# encoding: utf-8
class AdGroupKeywordsController < ApplicationController
  layout 'ads'
  before_filter :authenticate_advertiser!
  before_filter :set_campaigns_up

  def index
    if params[:ad_group_id]
      @ad_group = current_advertiser.ad_groups.where(id: params[:ad_group_id]).first
    elsif params[:campaign_id]
      @campaign = current_advertiser.ad_campaigns.where(id: params[:campaign_id]).first
    end

  end

  def show

  end

  def new

  end

  def create

  end

  private

  def set_campaigns_up
    @advertiser_campaigns = current_advertiser.ad_campaigns
    @advertiser_ad_groups = current_advertiser.ad_groups.group_by(&:ad_campaign_id)
  end
end