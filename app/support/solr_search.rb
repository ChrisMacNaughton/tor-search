class SolrSearch
  attr_accessor :page

  def initialize(query = '', page=1)
    @query = query
    @solr = RSolr.connect :url => 'http://localhost:8983/solr'
    @page = page
    @errors = []
    true
  end

  def query=(arg)
    @query = arg
    clear_args
  end

  def page=(page)
    @page = page
    clear_args
  end

  def search
    records
  end

  def records
    @records ||= response.try(:docs) || []
  end

  def total
    @total ||= response.try(:numFound).to_i
  end

  def total_pages
    @total_pages ||= (-(total.to_f/10)).floor.abs
  end

  def highlights
    @highlights ||= nutch.try(:highlighting) || []
  end

  def term
    @query
  end

  def current_page
    @page
  end

  def indexed
    begin
      get_solr_size
    rescue
      @errors = []
      @errors << "Search offline"
      0
    end
  end

  def errors
    nutch

    @errors
  end

  private

  def nutch
    return {} if @query.nil?
    @result ||= begin
      OpenStruct.new JSON.parse(@solr.get('nutch', :params => param).response[:body])
    rescue
      @errors << "Search offline"
      OpenStruct.new(error: "Failure to communicate with the Solr server")
    end
  end

  def response
    OpenStruct.new(nutch.try(:response) || {})
  end

  def get_solr_size
    path = 'http://localhost:8983/solr/admin/cores?wt=json'
    num_docs = read_through_cache('index_size', 24.hours) do
      json = Net::HTTP.get(URI.parse(path))
      JSON.parse(json)['status']['collection1']['index']['numDocs']
    end
  end
  def read_through_cache(cache_key, expires_in, &block)
    # Attempt to fetch the choice values from the cache, if not found then retrieve them and stuff the results into the cache.
    if TorSearch::Application.config.action_controller.perform_caching
      Rails.cache.fetch(cache_key, expires_in: expires_in, &block)
    else
      yield
    end
  end
  def param
    if @p.nil?
      @p = with_title(with_site(defaults))
    end
    @p
  end
  def with_title(q)
    if q[:q].include? 'title:'
      match = q[:q].match(/title:(\S+)/i)
      title = match[1]
      fq = "title:#{title}"
      if q[:q].include? '-title:'
        fq = "-#{fq}"
      end
      q[:q].gsub!(match[0], '')
      q[:fq] << fq
    end
    q
  end
  def with_site(q)
    if q[:q].include? 'site:'
      site = q[:q].match(/site:\s*(https?:\/\/)?(.{16}.onion)/i).to_a.last.gsub(/\.onion\/?$/, '')
      unless site.nil?
        fq = "id:onion.#{site}*"
        if q[:q].include? '-site:'
          fq = "-#{fq}"
        end
        q[:q].gsub!(/site:\s*(.{16}.onion)/i, '')
        q[:fq] << fq
        q[:group] = false
      end
    end
    q
  end

  def defaults
    {
      start: (@page - 1) * 10,
      q: @query,
      rows: 10,
      wt: 'json',
      fq: [],
      mm: '2<-1 6<70%',
      group: true,
      'group.field' => 'host',
      'group.main'=> true
    }
  end
  def clear_args
    @result = nil
    @records = nil
    @total = nil
    @total_pages = nil
    @highlights = nil
  end
end