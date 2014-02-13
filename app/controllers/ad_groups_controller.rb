# encoding: utf-8
class AdGroupsController < ApplicationController
  layout 'ads'
  before_filter :authenticate_advertiser!
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

  def new
    @ad_group = AdGroup.new
    @ad_group.ad_campaign_id = params[:campaign_id] if params[:campaign_id]

    @ad = Ad.new(advertiser: current_advertiser, title: 'Example Title', protocol_id: 0, path: 'www.example.com?rel=ts', display_path: 'www.example.com', line_1: 'this is an', line_2: 'example ad', bid: 0.0001)
  end

  def create
    @ad_group = AdGroup.new(params[:ad_group])
    @ad_group.advertiser_id = current_advertiser.id

    if @ad_group.save
      @ad = Ad.new(params[:ad])
      @ad.ad_group_id = @ad_group.id
      @ad.advertiser_id = current_advertiser.id
      if @ad.save
        redirect_to ad_group_path(@ad_group)
      else
        render "new"
      end
    else
      render "new"
    end
  end

  private

  def set_campaigns_up
    @advertiser_campaigns = current_advertiser.ad_campaigns
    @advertiser_ad_groups = current_advertiser.ad_groups.group_by(&:ad_campaign_id)
  end
end