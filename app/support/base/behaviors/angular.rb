module Base::Behaviors::Angular
  extend ActiveSupport::Concern
  included do
    after_filter  :set_csrf_cookie_for_ng
  end

  protected
  def paginated_results_hash(results, opt={})
    serialized_results = if opt[:serializer]
      results.map{|r| opt[:serializer].new(r)}
    else
      results
    end


    {
      total_pages:   results.total_pages,
      current_page:  results.current_page,
      per_page:      results.per_page,
      total_entries: results.total_entries,
      records:       serialized_results
    }
  end

  def verified_request?
    super || form_authenticity_token == request.headers['X_XSRF_TOKEN']
  end

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

end