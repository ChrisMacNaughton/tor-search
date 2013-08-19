class AdsController < ApplicationController
  before_filter :authenticate_advertiser!, except: :advertising
  def index
    Pageview.create(search: false, page: "AdsIndex")
    page = (params[:page] || 1).to_i
    per_page = (params[:per_age] || 20).to_i
    @ads = current_advertiser.ads.page(page).per_page(per_page).order(:created_at)
  end
  def new
    Pageview.create(search: false, page: "AdsCreate")
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
    Pageview.create(search: false, page: "AdsContact")
    @advertising = true
    render 'contact/contact'
  end
  def toggle
    ad = Ad.find(params[:id])
    ad.disabled = !ad.disabled
    if ad.save
      flash.notice = "Ad Toggled"
    else
      flash.error = "There was a problem, try again soon!"
    end
    redirect_to :ads
  end
end
