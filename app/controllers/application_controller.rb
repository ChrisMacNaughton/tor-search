class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_locale
  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { locale: I18n.locale }
  end
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  def track
    return true unless Rails.env.include? 'production'
    return if params[:q]

    Tracker.new(request).track!
  end
  def after_sign_in_path_for(resource)
    if resource.is_a? Admin
      rails_admin_path
    else
      ads_path
    end
  end
  protected
  def self.custom_exception_handling
    rescue_from Exception,                           with: :render_500
    rescue_from ActionController::RoutingError,      with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from AbstractController::ActionNotFound,  with: :render_404
    rescue_from ActiveRecord::RecordNotFound,        with: :render_404
    rescue_from Encoding::CompatibilityError,        with: :render_406
  end

  # Override for custom pages
  # see http://ramblinglabs.com/blog/2012/01/rails-3-1-adding-custom-404-and-500-error-pages
  custom_exception_handling \
    unless Rails.application.config.consider_all_requests_local

  def render_404(error=nil)
    unless error.nil?
      logger.warn error.message
      logger.warn error.backtrace.join("\n")
    end
    respond_to do |format|
      format.html { render template: 'errors/error_404', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
    true
  end

  def render_500(error)
    @error = error
    unless error.nil?
      logger.error error.message
      logger.error error.backtrace.join("\n")
    end

    respond_to do |format|
      format.html{
        if request.xhr?
          render json: "We're sorry, but something went wrong.\nWe've been notified about this issue and we'll take a look at it shortly.", status: 500
        else
          render template: 'errors/error_500', status: 500
        end
      }
      format.json{
        render json: "We're sorry, but something went wrong.\nWe've been notified about this issue and we'll take a look at it shortly.", status: 500
      }
    end
    true
  end

  def render_406(error)
    @error = error
    unless error.nil?
      logger.warn error.message
      logger.warn error.backtrace.join("\n")
    end
    render text: "Improperly encoded request", status: 406 and return
  end
end
