# encoding: utf-8
class AdsCommonController < ApplicationController
  layout 'ads'
  before_filter :authenticate_advertiser!
  before_filter :set_campaigns_up
  before_filter :track
  before_filter :notify_about_balance

  def notify_about_balance
    return if current_advertiser.nil?
    if current_advertiser.balance <= 0
      icon = "<i class='icon-exclamation-sign'></i>"
      message = "<strong>Your ads aren't running because your account balance is exhausted.</strong> - Please make a payment."
      link = "<strong><a href='#{billing_path}'>Fix It</a></strong>"
      flash.now[:alert] = "#{icon} #{message} #{link}".html_safe
    end
  end

  def set_campaigns_up
    return if current_advertiser.nil?
    @advertiser_campaigns = current_advertiser.ad_campaigns.order(:name)
    @advertiser_ad_groups = current_advertiser.ad_groups.order(:name).group_by(&:ad_campaign_id)
  end

  def track
    Tracker.new(request).track_later!
  end
end