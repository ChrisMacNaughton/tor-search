class Admin::AdvertisersController < Admin::BaseController
  def index
    page = (params[:page] || 1).to_i
    @advertisers = Advertiser.page(page).per_page(10).order(:created_at)
  end

  def show
    @advertiser = Advertiser.find(params[:id])
  end

  def credit
    Payment.create(advertiser_id: params[:advertiser_id], amount: params[:payment][:amount])
    redirect_to admin_advertiser_path(params[:advertiser_id])
  end
end
