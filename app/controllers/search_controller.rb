require "matcher/matcher"
class SearchController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def index
    if params[:q]
      search
    else
      track
      @search = SolrSearch.new
      render :index
    end
  end

  def search
    if params[:q].empty?
      render :index and return
    end
    page = params[:page] || 1
    @search = SolrSearch.new(params[:q], page)

    track! @search
    if @search.errors.empty?
      @query = Query.find_or_create_by_term(@search.term)

      s = Search.create(query: @query, results_count: @total, paginated: @paginated)
      @search_id = s.id

      if page == 1
        @paginated = false
        @ads = AdFinder.new(@search.term).ads
        @ads.each_with_index do |ad, idx|
          AdView.create(ad_id: ad.id, query_id: @query.id, position: idx+1)
        end
        @ads << AdFinder.amazon_ad(@search.term) if @ads.count < 5
      else
        @paginated = true
        @ads = []
      end
      @instant = true
      if params[:j] != "t"
        s.update_attribute(:js_enabled, false)
        @instant = false
        @instant_matches = Matcher.new(@search.term, request).execute || []
      end
    end

    render :search
  end

  def track!(search)
    return if Rails.env.include? 'development'

    Tracker.new(request, {term: search.term, count: search.total}, "Search").track!
  end

  def redirect
    search = Search.where(id: params[:s]).first
    target = params[:p]

    Click.create(search: search, target: target)
    if params[:j]
      render text: {status: 'ok'} and return
    else
      redirect_to params[:p]
    end
  end

  def ad_redirect
    ad = Ad.where(id: params[:id]).first
    if ad.nil?
      path = Base64.decode64(params[:path])
    else
      ad_click = AdClick.find_or_initialize_by_ad_id_and_query_id_and_search_id(ad.id, params[:q], params[:s])
      #debugger
      if ad_click.new_record?
        ad_click.save
        adv = ad.advertiser
        cost = ad.bid
        bal = adv.balance - cost
        logger.info ("CLICK: New balance for #{adv.email} is #{bal} after removing ad's bid (#{cost})")
        adv.balance= bal
        adv.save
      end
      path = ad.protocol + ad.path
    end
    redirect_to path, status: 302
  end
end
