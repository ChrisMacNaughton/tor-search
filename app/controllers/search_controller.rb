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
    if params[:q].empty?
      track
      @search = SolrSearch.new
      render :index and return
    end
    @mixpanel_tracker.track(current_advertiser.id, 'searched', {term: params[:q]}, visitor_ip_address) \
      if current_advertiser
    @query = Query.find_or_create_by_term(params[:q])

    if params[:q].include? '@'
      require 'bang'
      bang = Bang.new(params[:q])

      s = OpenStruct.new(term: params[:q], total: 1)
      if bang.has_target?
        InstantResult.create(query: @query, bang_match: bang.bang)
        track!(s) && redirect_to(bang.redirect_target) and return
      end
    end

    page = (params[:page] || 1).to_i
    @search = SolrSearch.new(params[:q], page)
    track! @search
    if @search.errors.empty?
      if page == 1
        @paginated = false
        @ads = AdFinder.new(@search.term).ads
        @ads.each_with_index do |ad, idx|
          res = AdView.create!(ad_id: ad.id, query_id: @query.id, position: idx + 1, keyword_id: ad.keyword_id)
          Rails.logger.warn {"An ad view wasn't created?! (ad: #{ad.id}, query: #{query.id}"} \
              unless res
        end
      else
        @paginated = true
        @ads = []
      end
      s = Search.create(
          query: @query,
          results_count: @search.total,
          paginated: @paginated
        )

      @search_id = s.id
      @instant = true
      if params[:j] != 't'
        s.update_attribute(:js_enabled, false)
        @instant = false
        @instant_matches = Matcher.new(@search.term, request).execute || []
      end
    end
    Rails.logger.info { @search.errors } unless @search.errors.empty?

    render :search
  end

  def track!(search)
    return true unless Rails.env.include? 'production'

    Tracker.new(
      request, { term: search.term, count: search.total }, 'Search'
    ).track_later!
  end

  def redirect
    target = params[:p]
    if target.nil?
      index and return
    end

    Click.create(search_id: params[:s], target: target)
    target = CGI.escape(target).gsub("%3A", ":").gsub("%2F", "/")
    redirect_to target, status: 302
  end

  def ad_redirect
    ad = Ad.where(id: params[:id]).first
    if ad.nil?
      index && return if parms[:path].nil?
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
          ad_click.keyword_id = params[:k]
          cost = AdGroupKeyword.where(keyword_id: params[:k]).first.try(:bid) || ad.ad_campaigns.default_bid
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
    path = path.gsub("{{app_path}}", request.env['HTTP_HOST'])
    if path.include? request.env['HTTP_HOST']
      path = CGI.escape(path).gsub("%3A", ":").gsub("%2F", "/")
      if request.ssl?
        replace = 'https'
      else
        replace = 'http'
      end
      path.gsub!(/https?/, replace)
    else
      path = CGI.escape(path).gsub("%3A", ":").gsub("%2F", "/")
    end
    redirect_to path, status: 302
  end
  # rubocop:enable  MethodLength
end
# rubocop:enable ClassLength
