require 'query_serializer'
require 'ad_serializer'
class Admin::AdController < AdminController
  include ModelFromParams
  after_filter  :set_csrf_cookie_for_ng
  def index
    #debugger
    respond_to do |format|
      format.json {
        render json: {
            current_page:  current_page,
            per_page:      per_page,
            total_entries: filtered_objects.total_entries,
            total_pages:   filtered_objects.total_pages,
            records:       filtered_objects_for_json
          }
        }
      end
  end
  def update
    render json: {success: Ad.find(params[:id]).update_attributes(params[:ad])}
  end
  protected
  def verified_request?
    super || form_authenticity_token == request.headers['X_XSRF_TOKEN']
  end
  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end
  private

  def associated_model_serializer
    unless @associated_model_serializer_lookup_complete
      c = "#{associated_model}Serializer"
      @associated_model_serializer = if Object.const_defined?(c)
        Rails.logger.debug("Using #{c}")
        c.constantize
      else
        Rails.logger.debug("No serializer #{c}")
        nil
      end
      @associated_model_serializer_lookup_complete = true
    end
    @associated_model_serializer
  end
  def filtered_objects_for_json

    if associated_model_serializer
      filtered_objects.map{|r| associated_model_serializer.new(r)}
    else
      filtered_objects
    end
  end
  def associated_model_name
    @model_name ||= 'ad'
  end

end