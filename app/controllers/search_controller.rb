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
    @search_term = params[:q]

    if @search_term.include? 'site:'
      site = @search_term.match(/site:\s*(.{16}.onion)/i)[0].gsub(/site:\s*/, '').gsub(/\/$/, '')
    end

    page = params[:page] || 1
    filters = {}
    filters[:with] = {}
    unless site.nil?
      domain = Domain.where(path: site).first
      unless domain.nil?
        filters[:with][:domain_id] = domain.id
      end
    end
    term = @search_term
    @search = Page.search {
      [:with, :without].each do |meth|
        Array(filters[meth].keys).each do |k|
          send(meth, k, filters[meth][k])
        end if filters.include?(meth)
      end
      fulltext term do
        boost_fields links: 50, title: 15
        phrase_fields title: 2.0, links: 4.0
        phrase_slop 2
        query_phrase_slop 2
        boost(2.0) { with(:links_count, 0.0..10.0)}
        boost(3.0) { with(:links_count, 10.0..25.0)}
        boost(4.0) { with(:links_count, 25.0..100.0)}
        boost(5.0) { with(:links_count, 100.0..500.0)}
        boost(6.0) { with(:links_count).greater_than(500)}
      end
      if site.nil?
        group :domain_id
      end
      paginate :page => params[:page], :per_page => 10

      adjust_solr_params do |p|
        p[:'group.main'] = true
      end
    }

    s = Search.create(query: params[:q], results_count: @search.total)
    @search_id = s.id
    render :search
  end
  def redirect
    page = Page.find(params[:p])

    search = Search.find(params[:s])


    Click.create(search: search, page: page)

    redirect_to page.url and return
  end
end
