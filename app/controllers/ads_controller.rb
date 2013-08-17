class AdsController < ApplicationController
  before_filter :authenticate_advertiser!, except: :advertising
  def index

  end
  def new
    @ad = Ad.new
  end
  def create
    @ad = Ad.new(params[:ad])
    @ad.advertiser = current_advertiser
    if @ad.save
      flash.notice = "Your new ad has been successfully created"
      redirect_to ads_path
    else
      render :new
    end
  end
  def advertising #expressing interest page
    @advertising = true
    render 'contact/contact'
  end
end
