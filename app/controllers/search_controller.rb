# encoding: utf-8
require 'matcher/matcher'
# rubocop:disable ClassLength
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
  # rubocop:disable MethodLength
  def search
    render :index && return if params[:q].empty?

    @query = Query.find_or_create_by_term(params[:q])

    if params[:q].include? '@'
      require 'bang'
      bang = Bang.new(params[:q])

      s = OpenStruct.new(term: params[:q], total: 1)
      if bang.has_target?
        InstantResult.create(query: @query, bang_match: bang.bang)
        track!(s) && redirect_to(bang.redirect_target) && return
      end
    end

    page = params[:page] || 1
    @search = SolrSearch.new(params[:q], page)
    track! @search
    puts @search.errors
    if @search.errors.empty?
      s = Search.create(
        query: @query,
        results_count: @total,
        paginated: @paginated
      )
      @search_id = s.id

      if page == 1
        @paginated = false
        @ads = AdFinder.new(@search.term).ads
        @ads.each_with_index do |ad, idx|
          AdView.create(ad_id: ad.id, query_id: @query.id, position: idx + 1)
        end
      else
        @paginated = true
        @ads = []
      end
      @instant = true
      if params[:j] != 't'
        s.update_attribute(:js_enabled, false)
        @instant = false
        @instant_matches = Matcher.new(@search.term, request).execute || []
      end
      puts @search.errors unless @search.errors.empty?
    end

    render :search
  end

  def track!(search)
    return true unless Rails.env.include? 'production'

    Tracker.new(
      request, { term: search.term, count: search.total }, 'Search'
    ).track!
  end

  def redirect
    search = Search.where(id: params[:s]).first
    target = params[:p]

    Click.create(search: search, target: target)
    if params[:j]
      render text: { status: 'ok' } && return
    else
      redirect_to params[:p]
    end
  end

  def ad_redirect
    ad = Ad.where(id: params[:id]).first
    if ad.nil?
      path = Base64.decode64(params[:path])
    else
      ad_click = AdClick \
        .find_or_initialize_by_ad_id_and_query_id_and_search_id(
          ad.id, params[:q], params[:s]
        )

      if ad_click.new_record?
        if params[:k].nil?
          cost = ad.bid
          bid_source = 'ad'
        else
          cost = AdKeyword.where(id: params[:k]).first.bid || ad.bid
          bid_source = 'keyword'
        end
        ad_click.save
        adv = ad.advertiser

        bal = adv.balance - cost
        log_message = "CLICK: New balance for #{adv.email} is #{bal} after"
        log_message << " removing #{bid_source}'s bid (#{cost})"
        logger.info log_message
        adv.balance = bal
        adv.save
      end
      path = ad.protocol + ad.path
    end
    redirect_to path, status: 302
  end
  # rubocop:enable  MethodLength
end
# rubocop:enable ClassLength
