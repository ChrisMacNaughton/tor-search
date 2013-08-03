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
      redirect_to root_path and return
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
=begin
    @search = Page.search {
      [:with, :without].each do |meth|
        Array(filters[meth].keys).each do |k|
          send(meth, k, filters[meth][k])
        end if filters.include?(meth)
      end
      fulltext term do
        #boost_fields anchor: 50, title: 15
        phrase_slop 2
        query_phrase_slop 2

      end
      adjust_solr_params do |p|
        p[:fq].delete_if{|a| !a.match(/type/).nil?}
        unless site.nil?
          p[:fq] << "id:*#{site}*"
        end
        p.delete(:fq) if p[:fq].empty?
      end
      paginate :page => params[:page], :per_page => 10
    }
=end
    solr = RSolr.connect :url => 'http://localhost:8983/solr'
    @page = (params[:page] || 1).to_i
    p = {
      fl: "* score",
      start: @page * 10,
      q: @search_term,
      qf: 'title content url anchor_texts path_texts',
      qs: 2,
      wt: 'json',
      rows: 10,
      ps: 2,
      defType: 'dismax'
    }
    search = JSON.parse(solr.get('select', :params => p).response[:body])
    @total = search['response']['numFound']
    @total ||= 0
    @total = @total.to_i
    @docs = search['response']['docs']
    @docs ||= []
    #debugger
    session[:searches] ||= []
    unless session[:searches].include? params[:q]
      s = Search.create(query: params[:q], results_count: @total)
      session[:searches] << params[:q]

      @search_id = s.id
      pubnub.publish(
        channel: :searches,
        message: {id: s.id, term: params[:q]},
        callback: lambda { |message| puts(message) }
      )
    end

    render :search
  end
  def redirect
    page = Page.where(id: params[:p]).first

    search = Search.where(id: params[:s]).first


    Click.create(search: search, page: page)

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
