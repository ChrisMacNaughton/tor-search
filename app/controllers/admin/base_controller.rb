class Admin::BaseController < ActionController::Base
  include CacheSupport
  include TorMethods
  force_ssl unless Proc.new { ssl_configured?  && is_tor? }

  before_filter :authenticate_admin!
  layout 'admin'
end