class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :track

  def index

  end
  def new
  end
  def track
    #return if Rails.env.include? 'development'
    return if !!(params[:controller] =~ /admin/)
    return if params[:q]
    Thread.new do
      Tracker.new(request).track!
    end.join
  end
  def get_solr_size
    path = 'http://localhost:8983/solr/admin/cores?wt=json'
    @num_docs = read_through_cache('index_size', 24.hours) do
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
  def read_through_cache(cache_key, expires_in, &block)
    # Attempt to fetch the choice values from the cache, if not found then retrieve them and stuff the results into the cache.
    if TorSearch::Application.config.action_controller.perform_caching
      Rails.cache.fetch(cache_key, expires_in: expires_in, &block)
    else
      yield
    end
  end
end
