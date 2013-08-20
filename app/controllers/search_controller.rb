class SearchController < ApplicationController
  def index
    get_solr_size
    if params[:q]
      Pageview.create(search: true, page: params[:q])
      search
    else
      Pageview.create(search: false, page: "Home")
      @total_pages_indexed = get_solr_size#Page.indexed.count
      render :index
    end
  end

  def search
    if params[:q].empty?
      render :index and return
    end
    pubnub = Pubnub.new(
      :publish_key   => Rails::application.config.tor_search.pub_nub.publish_key,
      :subscribe_key => Rails::application.config.tor_search.pub_nub.subscribe_key,
      :secret_key    => Rails::application.config.tor_search.pub_nub.secret_key,
      :cipher_key    => Rails::application.config.tor_search.pub_nub.cipher_key,
      :ssl           => Rails::application.config.tor_search.pub_nub.ssl
    )
    @search_term = params[:q]

    page = params[:page] || 1
    filters = {}
    filters[:with] = {
    }

    solr = RSolr.connect :url => 'http://localhost:8983/solr'
    @page = (params[:page] || 1).to_i
    p = {
      start: (@page - 1) * 10,
      q: @search_term,
      rows: 10,
      wt: 'json',
      mm: '2<-1 5<-2 6<90%'
    }
    if @search_term.include? 'site:'
      site = @search_term.match(/site:\s*(.{16}.onion)/i)[0].gsub(/site:\s*/, '').gsub(/\.onion\/?$/, '')
      fq = "id:onion.#{site}*"
      if @search_term.include? '-site:'
        fq = "-#{fq}"
      end
      p[:q].gsub!(/site:\s*(.{16}.onion)/i, '')
      p[:fq] = fq
    end
    #debugger
    search = JSON.parse(solr.get('nutch', :params => p).response[:body])
    @total = search['response']['numFound']
    @total ||= 0
    @total_pages = (-(@total.to_f/10)).floor.abs
    @total = @total.to_i
    Thread.new do
      Tracker.new(request, {term: @search_term, count: @total}, "Search").track!
    end.join
    @highlights = search['highlighting']
    @docs = search['response']['docs']
    @docs ||= []
    #debugger
    @query = Query.find_or_initialize_by_term(@search_term)
    @query.save
    if params[:page].nil? || params[:page] == 1
      s = Search.create(query: @query, results_count: @total)
      @search_id = s.id
      pubnub.publish(
        channel: :searches,
        message: {id: @search_id, term: params[:q]},
        callback: lambda { |message| puts(message) }
      )
    end
    @ads = ads
    ad_ids = @ads.map(&:id)
    @ads.each do |ad|
      adv = ad.advertiser
      cost = ad.onion? ? ad.bid : 2.0 * ad.bid
      bal = adv.balance - cost
      logger.info ("New balance for #{adv.email} is #{bal} after removing ad's bid (#{cost})")
      adv.balance= bal
      adv.save
      AdView.create(ad_id: ad.id, query_id: @query.id)
    end
    render :search
  end
  def redirect
    search = Search.where(id: params[:s]).first
    target = params[:p]

    Click.create(search: search, target: target)
    render text: {status: 'ok'} and return
  end
  def ads
    Ad.page(1).available.joins(:advertiser).where('advertisers.balance > ads.bid').order(:created_at, :bid)
  end
end
