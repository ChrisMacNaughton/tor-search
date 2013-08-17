class AdminController < ApplicationController
  newrelic_ignore
  before_filter :authenticate_admin!

  layout 'admin'

  def index

  end
  def clicks
    respond_to do |format|
      format.json do
        limit = params[:limit] || 10
        s = Search.find(params[:id])
        clicks = s.clicks.limit(limit).
          page(params[:page])
        clicks = clicks.map do |c|
          {id: c.id, page_id: c.page_id}
        end
        meta = {total_clicks: s.clicks.count}
        render json: {meta: meta, clicks: clicks}
      end
    end
  end
end
