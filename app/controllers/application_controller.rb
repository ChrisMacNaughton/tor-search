class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index

  end

  def new
  end

  def track
    return if Rails.env.include? 'development'
    return if params[:q]

    Tracker.new(request).track!
  end
end
