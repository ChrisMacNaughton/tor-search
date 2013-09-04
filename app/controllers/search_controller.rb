class SearchController < ApplicationController
  def index
    if params[:q]
      search
    else
      @total_pages_indexed = get_solr_size
      render :index
    end
  end

  def search
    if params[:q].empty?
      render :index and return
    end
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
    @highlights = search['highlighting']
    @docs = search['response']['docs']
    @docs ||= []
    #debugger
    @query = Query.find_or_create_by_term(@search_term)
    @paginated = if params[:page].nil? || params[:page] == "1"
      false
    else
      true
    end
    s = Search.create(query: @query, results_count: @total, paginated: @paginated)
    @search_id = s.id

    if params[:page].nil? || params[:page] == 1
      @ads = AdFinder.new(@search_term).ads
      @ads.each_with_index do |ad, idx|
        AdView.create(ad_id: ad.id, query_id: @query.id, position: idx+1)
      end
    else
      @ads = []
    end

    render :search
  end
  def redirect
    search = Search.where(id: params[:s]).first
    target = params[:p]

    Click.create(search: search, target: target)
    render text: {status: 'ok'} and return
  end
  def ad_redirect
    ad = Ad.find(params[:id])

    ad_click = AdClick.find_or_initialize_by_ad_id_and_query_id_and_search_id(ad.id, params[:q], params[:s])
    #debugger
    if ad_click.new_record?
      ad_click.save
      adv = ad.advertiser
      cost = ad.onion? ? ad.bid : 2.0 * ad.bid
      bal = adv.balance - cost
      logger.info ("CLICK: New balance for #{adv.email} is #{bal} after removing ad's bid (#{cost})")
      adv.balance= bal
      adv.save
    end
    redirect_to ad.protocol + ad.path, status: 302
  end
end
