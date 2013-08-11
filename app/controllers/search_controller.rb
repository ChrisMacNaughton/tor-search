class SearchController < ApplicationController
  def index
    get_solr_size
    if params[:q]
      search
    else
      @total_domains_found = Domain.active.count
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

    if @search_term.include? 'site:'
      #site = @search_term.match(/site:\s*(.{16}.onion)/i)[0].gsub(/site:\s*/, '').gsub(/\.onion\/$/, '')
    end

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
    search = JSON.parse(solr.get('nutch', :params => p).response[:body])
    @total = search['response']['numFound']
    @total ||= 0
    @total_pages = (-(@total.to_f/10)).floor.abs
    @total = @total.to_i
    @highlights = search['highlighting']
    @docs = search['response']['docs']
    @docs ||= []
    #debugger
    query = Query.find_or_initialize_by_term(@search_term)
    query.save
    s = Search.create(query: query, results_count: @total)
    @search_id = s.id
    pubnub.publish(
      channel: :searches,
      message: {id: @search_id.id, term: params[:q]},
      callback: lambda { |message| puts(message) }
    )


    render :search
  end
  def redirect
    search = Search.where(id: params[:s]).first
    target = params[:p]

    Click.create(search: search, target: target)
    render text: {status: 'ok'} and return
  end

  def flag
    session[:refer] = request.referer
    @page = Page.find(params[:id])
    @flag = ContentFlag.new(content: @page)
    @nav = false
    render 'flag'
  end
  def complete_flag
    page = Page.find(params[:post][:content_id])
    reason = FlagReason.where(id: params[:flag_reason]).first
    flag = ContentFlag.create(content: page, reason: params[:post][:reason], flag_reason: reason)
    flash.notice = "Thank you for your flag!"
    refer = session[:refer] || root_path
    session[:refer] = nil
    redirect_to refer
  end
end
