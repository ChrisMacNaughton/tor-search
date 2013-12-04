# encoding: utf-8
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_locale
  before_filter :check_is_onion
  before_filter :add_user_to_request
  before_filter :setup_mixpanel_tracker
  before_filter :notify_about_other_domain_for_tor_to_web

  def notify_about_other_domain_for_tor_to_web
    if is_tor2web?
      flash.now[:notice] = "You can improve your experience with TorSearch by browsing directly to <a href='https://torsearch.es'>TorSearch.es</a><br/>
Because you are using Tor2Web, you have already traded anonymity for convenience and now you can use TorSearch even faster!".html_safe
    elsif request_ip_is_exit?
      flash.now[:notice] = "You can access this site as a hidden service and use Tor's encryption by using <a href='http://kbhpodhnfxl3clb4.onion'>kbhpodhnfxl3clb4.onion</a>".html_safe
    end
  end

  def check_is_onion
    debugger
    @request_is_onion = !!(request.host =~ /onion/)
    if @request_is_onion
      if is_tor2web?
        request[:oniony] = 'tor2web'
      else
        request[:oniony] = 'tor'
      end
    else
      if request_ip_is_exit?
        request[:oniony] = 'tor_over_clear'
      else
        request[:oniony] = 'clear'
      end
    end
  end

  def add_user_to_request
    if current_advertiser
      request[:current_advertiser] = current_advertiser
    end
  end

  def setup_mixpanel_tracker
    require 'mixpanel-ruby'
    @mixpanel_tracker = Mixpanel::Tracker.new(TorSearch::Application.config.mixpanel_token)
    @mixpanel_tracker.people.set(current_advertiser.id, {
      '$email' => current_advertiser.email,
      'wants js' => current_advertiser.wants_js
    }) if current_advertiser
  end

  def request_ip_is_exit?
    ips = read_through_cache('exit_ips', 24.hours) do
      url = URI('https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=173.49.88.241&port=443')
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      r = Net::HTTP::Get.new(url.request_uri)
      response = http.start {|http| http.request(r)}
      response.body.split("\n").reject{|w| w[0] == '#'}
    end
    ips.include? request.ip
  end

  def is_tor2web?
    request.headers['X_TOR2WEB'] == 'encrypted'
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def track
    #return true unless Rails.env.include? 'production'
    return if params[:q]
    Tracker.new(request).track_later!
  end

  def after_sign_in_path_for(resource)
    if resource.is_a? Admin
      rails_admin_path
    else
      ads_path
    end
  end

  def visitor_ip_address
    if request[:oniony] == 'clear'
      request.remote_ip
    else
      '127.0.0.1'
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

  def render_404(error = nil)
    unless error.nil?
      logger.warn error.message
      logger.warn error.backtrace.join("\n")
    end
    respond_to do |format|
      @layout = false
      format.html { render template: 'error_404', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
    true
  end

  # rubocop:disable MethodLength
  def render_500(error)
    @error = error
    unless error.nil?
      logger.error error.message
      logger.error error.backtrace.join("\n")
      notify_airbrake(error)
    end
    respond_to do |format|
      format.html do
        @nav = false
        render template: 'error_500', status: 500
      end
    end
    true
  end
  # rubocop:enable MethodLength

  def render_406(error)
    @error = error
    unless error.nil?
      logger.warn error.message
      logger.warn error.backtrace.join("\n")
    end
    render text: 'Improperly encoded request', status: 406 and return
  end

  def read_through_cache(cache_key, expires_in, &block)
    # Attempt to fetch the choice values from the cache,
    # if not found then retrieve them and stuff the results into the cache.
    if TorSearch::Application.config.action_controller.perform_caching
      Rails.cache.fetch(cache_key, expires_in: expires_in, &block)
    else
      yield
    end
  end
end
