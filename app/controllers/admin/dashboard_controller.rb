class Admin::DashboardController < Admin::BaseController
  def index
    base_cache_time = 10.minutes
    @dashboard_params = HashWithIndifferentAccess.new({
      advertiser_count: read_through_cache('advertiser_count', base_cache_time) { Advertiser.count },
      new_advertiser_count: read_through_cache('new_advertiser_count', base_cache_time) { Advertiser.where(created_at: (24.hours.ago..Time.now)).count },
      pending_ads_count: read_through_cache('pending_ads_count', base_cache_time) { Ad.where(approved: false).count },
      active_ads_count: read_through_cache('active_ads_count', base_cache_time) { Ad.joins(:advertiser).where('advertisers.balance > 0').where(approved: true, disabled: false).count },
      current_search_count: read_through_cache('current_search_count', 12.hours) { Search.where(created_at: (7.days.ago..Time.now)).count },
      previous_search_count: read_through_cache('previous_search_count', 12.hours) { Search.where(created_at: (14.days.ago..7.days.ago)).count }
    })
  end
end
