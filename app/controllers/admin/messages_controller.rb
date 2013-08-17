class Admin::MessagesController < AdminController
  include ModelFromParams
  def index
    respond_to do |format|
      format.html {

      }
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
  def page
    (params[:page] || 1).to_i
  end
  def per_page
    (params[:per_page] || 10).to_i
  end
  private
  def associated_model_name
    @model_name ||= 'message'
  end
  def filtered_objects_for_json
    filtered_objects
  end
end