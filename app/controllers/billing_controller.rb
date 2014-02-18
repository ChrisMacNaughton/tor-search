# encoding: utf-8
class BillingController < ApplicationController
  layout 'ads'
  before_filter :authenticate_advertiser!
  before_filter :set_campaigns_up

  def index
    if current_advertiser.bitcoin_addresses.empty?
      flash.now[:notice] = "We've generated a new bitcoin address for you!"
      BitcoinAddress.generate_new_address(current_advertiser)
    end
    @transactions = {}
    @transactions[:this_month] = current_advertiser.payments.where(created_at: DateTime.now.beginning_of_month..DateTime.now)
    @transactions[:last_month] = current_advertiser.payments.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
    @transactions[:months_ago] = current_advertiser.payments.where(created_at: 2.months.ago.beginning_of_month..2.months.ago.end_of_month)
  end

  private

  def set_campaigns_up
    @advertiser_campaigns = current_advertiser.ad_campaigns.order(:name)
    @advertiser_ad_groups = current_advertiser.ad_groups.order(:name).group_by(&:ad_campaign_id)
  end
end
