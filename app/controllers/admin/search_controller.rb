require 'query_serializer'
class Admin::SearchController < AdminController
  include ModelFromParams
  def show
    @search = Search.where(id: params[:id]).includes(:query, {clicks: :page}).first
    @clicks = @search.clicks.map do |c|
      OpenStruct.new({id: c.id, url: c.target,body: get_body_from(c), title: get_title_from(c)})
    end
  end
  def index
    respond_to do |format|
      format.json {
        render json: {
            current_page:  current_page,
            per_page:      per_page,
            total_entries: filtered_objects.total_entries,
            total_pages:   filtered_objects.total_pages,
            records:       filtered_objects_for_json
          }
        }
      end
  end
  protected
  def with_includes(rel)
    rel.includes(:searches)
  end
  private

  def associated_model_serializer
    unless @associated_model_serializer_lookup_complete
      c = "#{associated_model}Serializer"
      @associated_model_serializer = if Object.const_defined?(c)
        Rails.logger.debug("Using #{c}")
        c.constantize
      else
        Rails.logger.debug("No serializer #{c}")
        nil
      end
      @associated_model_serializer_lookup_complete = true
    end
    @associated_model_serializer
  end
  def filtered_objects_for_json

    if associated_model_serializer
      filtered_objects.map{|r| associated_model_serializer.new(r)}
    else
      filtered_objects
    end
  end
  def associated_model_name
    @model_name ||= 'query'
  end

  def get_body_from(click)
    solr_page(click.target).try('fetch','content')
  end
  def get_title_from(click)
    solr_page(click.target).try('fetch','title')
  end
  private

  def solr_page(url)
    @pages ||= {}
    if @pages[url].nil?
      solr = RSolr.connect :url => 'http://localhost:8983/solr'
      split = url.gsub(/https?:\/\//, '').split(/\.onion/)
      id = "\"onion.#{split[0]}:http#{split[1]}\""
      p = {
        q: "id:#{id}",
        wt: 'json'
      }
      search = JSON.parse(solr.get('select', :params => p).response[:body])
      @pages[url] = search['response']['docs'].select{|c| c['url'] == url }.first
    end
    @pages[url]
  end
end