class Admin::BaseController < ActionController::Base
  include CacheSupport
  before_filter :authenticate_admin!
  layout 'admin'
end