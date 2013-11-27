# encoding: utf-8
# helper for search controller
module SearchHelper
  def include_more_links(search_term)
    @include_more ||= !search_term.include?('site:')
  end

  def convert_to_proxy(url)
    if @request_is_onion
      url
    else
      url.gsub(/([2-7a-zA-Z]{16})\.onion/, '\1.onion.to')
    end
  end
end
