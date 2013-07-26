class AdminController < ApplicationController
  newrelic_ignore
  before_filter :authenticate_admin!

  layout 'admin'

  def index

  end
  def status
    render json: {
      last_hour: {
        searches: Search.last_hour.count,
        most_popular: Search.most_popular(:last_hour, 1)[0].try(:first)
      },
      last_6_hours: {
        searches: Search.last_6_hours.count,
        most_popular: Search.most_popular(:last_6_hours, 1)[0].try(:first)
      },
      last_12_hours: {
        searches: Search.last_12_hours.count,
        most_popular: Search.most_popular(:last_12_hours, 1)[0].try(:first)
      },
      last_24_hours: {
        searches: Search.last_24_hours.count,
        most_popular: Search.most_popular(:last_24_hours, 1)[0].try(:first)
      },
      last_week: {
        searches: Search.last_week.count,
        most_popular: Search.most_popular(:last_week, 1)[0].try(:first)
      },
      last_month: {
        searches: Search.last_month.count,
        most_popular: Search.most_popular(:last_month, 1)[0].try(:first)
      },
    }
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
  def pages

  end
  def page

  end

end
