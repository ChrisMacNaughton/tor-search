# encoding: utf-8
# Handle building and executing our Solr query
# rubocop:disable ClassLength
class SolrSearch
  include CacheSupport

  attr_accessor :page
  attr_reader :current_page, :query

  alias_method :term, :query

  def initialize(query = '', page = 1)
    @query = query
    @solr = RSolr.connect url: solr_url
    @current_page = page.to_i
    @errors = []
    true
  end

  def config
    if @config.nil?
      @config = HashWithIndifferentAccess.new(YAML.load_file Rails.root.join('config','solr.yml'))
    end
    @config[Rails.env]
  end

  def query=(arg)
    @query = arg
    clear_args
  end

  def page=(page)
    @current_page = page
    clear_args
  end

  def search
    records
  end

  def group_field
    param['group.field']
  end

  def records
    @records ||= grouped.try(:[], 'doclist').try(:[], 'docs') || []
  end

  def total
    @total ||= grouped.try(:[], 'ngroups').to_i
  end

  def total_pages
    @total_pages ||= (-(total.to_f / 10)).floor.abs
  end

  def highlights
    @highlights ||= nutch.try(:highlighting) || []
  end

  def indexed
    get_solr_size || 0
  end

  def errors
    nutch

    @errors
  end

  private

  def solr_url
    "http://#{config[:hostname]}:#{config[:port]}/solr"
  end

  def grouped
    response.try(group_field.to_sym)
  end

  def nutch
    return {} if @query.nil?
    @result ||= begin
      solr = read_through_cache( Digest::SHA1.hexdigest(param.to_json), 30.minutes ) do
        @solr.get('nutch', params: param)
      end
      OpenStruct.new JSON.parse(solr.response[:body])
    rescue => ex
      @result = nil
      #Airbrake.notify(ex)
      Rails.logger.info ex
      Rails.logger.info ex.backtrace.join("\n")
      @errors << 'Search offline'
      OpenStruct.new(error: 'Failure to communicate with the Solr server')
    end
  end

  def response
    OpenStruct.new(nutch.try(:grouped) || {})
  end

  def get_solr_size
    path = "#{solr_url}/admin/cores?wt=json"
    read_through_cache('index_size', 1.hour) do
      json = Net::HTTP.get(URI.parse(path))
      JSON.parse(json)['status']['collection1']['index']['numDocs']
    end
  end

  def param
    @p ||= with_title(with_site(without_banned_hosts(defaults)))
  end

  def without_banned_hosts(q)
    unless banned_hosts.empty?
      banned = ""
      banned_hosts.each do |h|
        base = h.split(/\.onion/).first
        banned << "id:onion.#{base}\\:http/* OR "
      end
      q[:fq] << "-(#{banned.gsub(/\sOR\s$/, '')})"
    end
    q
  end
  # rubocop:disable MethodLength
  def with_title(q)
    if q[:q].include? 'title:'
      match = q[:q].match(/title:\s*(\S+)/i)
      unless match.nil?
        title = match[1]
        fq = "title:#{title}"
        fq = "-#{fq}" if q[:q].include? '-title:'
        q[:q].gsub!(match[0], '')
        q[:fq] << fq
      end
    end
    q
  end

  def with_site(q)
    if q[:q].include? 'site:'
      matches = q[:q].match(%r(site:\s*(https?://)?(.{16}.onion))i)
      match = matches.to_a.try(:last)
      site = match.gsub(/\.onion\/?$/, '') if match
      unless site.nil?
        fq = "id:onion.#{site}*"
        if q[:q].include? '-site:'
          fq = "-#{fq}"
        else
          q.delete(:'group.ngroups')
        end
        q[:q].gsub!(/-?site:\s*(.{16}.onion)/i, '')
        q[:fq] << fq
        q['group.field'] = 'id'
      end
    end
    q
  end
  # rubocop:enable MethodLength
  def defaults
    global_opts.merge(
      start: (@current_page - 1) * 10,
      q: @query.dup,
      fq: []
    )
  end

  def global_opts
    {
      mm: '2<-1 6<70%',
      group: true,
      'group.format' => 'simple',
      'group.field' => 'host',
      'group.ngroups' => true,
      'group.limit' => 3,
      rows: 10,
      wt: 'json'
    }
  end

  def clear_args
    @result = nil
    @records = nil
    @total = nil
    @total_pages = nil
    @highlights = nil
  end

  def banned_hosts
    BannedDomain.pluck(:hostname)
  end
end
# rubocop:enable ClassLength
