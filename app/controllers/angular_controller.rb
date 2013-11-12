# encoding: utf-8
class AngularController < ApplicationController
  before_filter :track, :authenticate_advertiser!

  def index
    respond_to do |format|
      format.html{
        render :index
      }
    end
  end

  def show
    respond_to do |format|
      format.html{
        render :index
      }
    end
  end

  def new
    respond_to do |format|
      format.html{
        render :index
      }
    end
  end

  def edit
    respond_to do |format|
      format.html{
        render :index
      }
    end
  end
end