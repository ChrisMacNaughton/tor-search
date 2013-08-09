class AdvertisingController < ApplicationController
  def advertising
    @advertising = true
    render 'contact/contact'
  end
end
