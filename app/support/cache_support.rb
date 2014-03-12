module CacheSupport
  def read_through_cache(cache_key, expires_in, &block)
    # Attempt to fetch the choice values from the cache,
    # if not found then retrieve them and stuff the results into the cache.
    if TorSearch::Application.config.action_controller.perform_caching
      Rails.cache.fetch(cache_key, expires_in: expires_in, &block)
    else
      yield
    end
  end

  def read_through_cache!(cache_key, expires_in, &block)
    Rails.cache.delete_matched(cache_key)
    read_through_cache(cache_key, expires_in, &block)
  end
end