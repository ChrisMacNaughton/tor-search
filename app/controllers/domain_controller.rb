# encoding: utf-8
class DomainController < ApplicationController

  def new
    track
    @domain = Domain.new
    @domain.use_captcha!
    @domain.textcaptcha
  end
  # rubocop:disable MethodLength
  def submit
    domain_params = params[:domain]
    domain_params.merge!(pending: true)
    @domain = Domain.new(domain_params)
    @domain.use_captcha!
    unless verified_request?
      flash.alert = 'This request is invalid!!!'
      render :new && return
    end

    if @domain.valid?
      @domain.save
      flash.notice = 'Thank you for your submission'
      flash.notice += ' it will be reviewed shortly!'
      redirect_to add_link_path
    else
      render :new
    end
  end
  # rubocop:enable MethodLength

  def flag_page
    redirect_to root_path and return if params[:search_id].nil?

    @flag = Flag.new(path: params[:path], query_id: Search.find(params[:search_id]).query_id)
  end

  def create_flag
    @flag = Flag.new(params[:flag])
    if @flag.save
      flash[:notice] = "Thank you for helping identify bad pages!"
      redirect_to root_path({q: @flag.query.term})
    else
      render :flag_page
    end
  end
end
