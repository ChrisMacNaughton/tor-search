class Admin::SearchController < ApplicationController
  newrelic_ignore
  results_with_params_for Search
  def show
    @search = Search.where(id: params[:id]).includes(clicks: :page).first
  end
  def index
    respond_to do |format|
      format.json do

        render text: paginated_results_hash(results_with_params(params)).to_json
      end
    end
  end

  def paginated_results_hash(results, opt={})
    serialized_results = if opt[:serializer]
      results.map{|r| opt[:serializer].new(r)}
    else
      results
    end
    {
      total_pages:   results.total_pages,
      current_page:  results.current_page,
      per_page:      results.per_page,
      total_entries: results.total_entries,
      records:       serialized_results
    }
  end
end