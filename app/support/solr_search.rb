class SolrSearch
  attr_accessor :page

  attr_reader :records, :total, :total_pages, :highlights
  def initialize(query, page=1)
    @query = query
    @solr = RSolr.connect :url => 'http://localhost:8983/solr'
    @page = page
  end

  def search
    records
  end

  def records
    @records ||= nutch['response']['docs'] || []
  end

  def total
    @total ||= nutch.try(:response).try(:numFound).to_i
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

  def self.indexed
    begin
      get_solr_size
    rescue
      0
    end
  end

  private

  def nutch
    @result ||= begin
      JSON.parse(@solr.get('nutch', :params => param).response[:body])
    rescue
      {error: "Failure to communicate with the Solr server"}
    end
  end
  def self.get_solr_size
    path = 'http://localhost:8983/solr/admin/cores?wt=json'
    num_docs = read_through_cache('index_size', 24.hours) do
      begin
        json = Net::HTTP.get(URI.parse(path))
      rescue => e
        if e.message.include? 'Address family not supported by protocol family'
          json = {status: {collection1: {index: { numDocs: 99872}}}}.to_json
        else
          raise
        end
      end
      #Rails.logger.info("Got some json from Solr: #{json}")
      JSON.parse(json)['status']['collection1']['index']['numDocs']
    end
  end
  def self.read_through_cache(cache_key, expires_in, &block)
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
      site = q[:q].match(/site:\s*(.{16}.onion)/i)[0].gsub(/site:\s*/, '').gsub(/\.onion\/?$/, '')
      fq = "id:onion.#{site}*"
      if q[:q].include? '-site:'
        fq = "-#{fq}"
      end
      q[:q].gsub!(/site:\s*(.{16}.onion)/i, '')
      q[:fq] << fq
    end
    q
  end

  def defaults
    {
      start: (@page - 1) * 10,
      q: @query,
      rows: 10,
      wt: 'json',
      mm: '2<-1 5<-2 6<90%',
      fq: []
    }
  end
end