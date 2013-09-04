class DomainController < ApplicationController
  def new
    @domain = Domain.new
    @domain.use_captcha!
    @domain.textcaptcha
  end
  def submit
    domain_params = params[:domain]
    domain_params.merge!(pending: true)
    @domain = Domain.new(domain_params)
    @domain.use_captcha!
    unless verified_request?
      flash.alert = "This request is invalid!!!"
      render :new and return
    end

    if @domain.valid?
      @domain.save
      flash.notice = "Thank you for your submission, it will be reviewed shortly!"
      redirect_to add_link_path
    else
      render :new
    end
  end
end
