class Admin::AdsController < Admin::BaseController
  def index
    page = (params[:page] || 1).to_i
    @ads = Ad.page(page).per_page(10)
  end

  def pending
    page = (params[:page] || 1).to_i
    @ads = Ad.pending.page(page).per_page(10)
  end

  def active
    page = (params[:page] || 1).to_i
    @ads = Ad.enabled.page(page).per_page(10)
    render :index
  end

  def edit
    @ad = Ad.find(params[:id])
  end

  def update
    @ad = Ad.find(params[:ad_id])
    if @ad.update_attributes(params[:ad])
      flash.notice = "Updated ad"
      redirect_to admin_ads_path
    else
      render :edit
    end
  end

  def toggle
    ad = Ad.find(params[:ad_id])
    ad.update_attribute(:approved, !ad.approved)
    if ad.approved?
      flash.notice = "Enabled ad"
    else
      flash.notice = "Disabled ad"
    end
    redirect_to :back and return
  end
end
