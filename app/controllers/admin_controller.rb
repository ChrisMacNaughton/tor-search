class AdminController < ApplicationController
  before_filter :authenticate_admin!

  layout 'admin'

  def index

  end
  def search
    @search = Search.where(id: params[:id]).includes(clicks: :page).first
  end
  def searches
    respond_to do |format|
      format.json do
        limit = params[:limit] || 10
        searches = Search.order('created_at desc').limit(limit).
          page(params[:page])

        searches = searches.map do |s|
          {id: s.id, term: s.query, total_results: s.results_count, total_clicks: s.clicks.count}
        end
        meta = {total_searches: Search.count}
        render text: searches.to_json
      end
    end
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
        render text: {meta: meta, clicks: clicks}.to_json
      end
    end
  end
  def pages

  end
  def page

  end
end
