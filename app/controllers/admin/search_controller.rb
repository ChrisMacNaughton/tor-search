require 'query_serializer'
class Admin::SearchController < AdminController
  include ModelFromParams
  def show
    @search = Search.where(id: params[:id]).includes(:query, {clicks: :page}).first
  end
  def index
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
  protected
  def with_includes(rel)
    rel.includes(:searches)
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
    @model_name ||= 'query'
  end
end