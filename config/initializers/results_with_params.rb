# This module provides a class method results_with_params_for() that allows customization of the
# behavior of the instance method results_with_params().
#
# The structure of the params hash is intended to match the controller's params object:
#  |- :search - Contains all search-relevant details.
#  |   |- :by - The attribute related to the search term.
#  |   |- :term - The search term for the "by" attribute.
#  |   |_ :advanced - Hash containing key/value pairs of additional search criteria. In order to use this,
#  |                      the class must implement "filter_by" (available from the KeyedScopes concern).
#  |_ :sort - Contains sort-relevant details. In order to use this, the model class must
#     |       implement "order_by" (available from the KeyedScopes concern).
#     |- params[:sort][:key] - The sort key.
#     |_ params[:sort][:direction] - The direction of the sort ("asc" or "desc").
module ResultsWithParams
  extend ActiveSupport::Concern
  include ActionView::Helpers::NumberHelper # for number_with_delimiter

  included do
    class_attribute :_results_with_params_options
  end

  # Options can include:
  #  * :default_sort - string passed to order() in case sort key/direction aren't included.
  #  * :wants_full_array - boolean to determine whether the relation is forced to a full array
  #    (see active_record_to_full_a.rb); default is false.
  #  * :include_search_term - boolean to determine whether search[:by] and search[:term] are
  #    included in the search; default is false.
  module ClassMethods
    def results_with_params_for(initial_rel, options = {})
      options[:initial_rel] = initial_rel
      self._results_with_params_options = options
    end
  end

  def merged_params(params = self.params)
    params ||= HashWithIndifferentAccess.new
    #
    # If we do not support saving the user search, do not look it up
    #
    stored_search = nil
    stored_search = Admin.current.searches.for_class(self.class).try(:first) \
      if Admin.current.present? && (!respond_to?(:supports_saved_search?) || self.send(:supports_saved_search?))

    stored_search ||= AdminSearch.new

    sort = HashWithIndifferentAccess.new(params[:sort] || {})
    sort.merge!(stored_search.sort_params)

    search = HashWithIndifferentAccess.new(params[:search] || {})
    search[:advanced] = HashWithIndifferentAccess.new(search[:advanced] || {})

    # Two-level hash merge. First merge in advanced, then merge in top-level search params. We do it this way to
    # merge the existing advanced hash with the new one, which is what would happen if we just merged
    # the top-level hash.
    search[:advanced].merge!(stored_search.search_params.delete(:advanced) || {})
    search.merge!(stored_search.search_params)

    terms = if self.class._results_with_params_options[:include_search_term]
      search[:advanced].merge({ search[:by] => search[:term] })
    else
      search[:advanced]
    end

    #
    # A very common thing to do is to want to search by category name.
    # In this section, we are translating and category name that is coming in
    # to the ids it represents for use in our filtering
    #
    if search[:category_name].present? && !search[:category_name].blank?
      cat_id = Category.where("lower(name) in (?)",
                              Array(search[:category_name]).map(&:downcase))
      related_cats = Category.where(
        "rgt - lft = 1 and exists (select 'x' from categories c where c.id in (?)
        and c.lft <= categories.lft and c.rgt >= categories.rgt)", cat_id).
        select("id").map(&:id)
      terms.merge!({category_id: related_cats})
    end

    HashWithIndifferentAccess.new(sort: sort, search: search, terms: terms)
  end

  def results_with_params(params, opts={})
    results_with_params_options = self.class._results_with_params_options.merge(opts)

    @merged_params = merged_params(params)

    sort = @merged_params[:sort]
    search = @merged_params[:search]
    terms = @merged_params[:terms]

    rel = results_with_params_options[:initial_rel]

    default_sort = Proc.new {rel.order(results_with_params_options[:default_sort] || "id desc")}

    if rel.respond_to? :order_by
      if sort[:key].present?
        rel = rel.order_by(sort[:key], sort[:direction])
      else
        unless params[:skip_default_sort]
          rel = default_sort.call
        end
      end
    elsif @merged_params[:sort]
      Rails.logger.warn "#{self.class}.results_with_params: sort params passed in but order_by not implemented."
    else
      unless params[:skip_default_sort]
        rel = default_sort.call
      end
    end

    if rel.respond_to? :filter_by
      terms.each do |key, value|
        value = Array(value).reject{|s| s == "null"}
        value = value[0] if value.size == 1
        rel = rel.filter_by(key, value) unless value.respond_to?(:empty?) && value.empty?
      end
    elsif terms.length > 0
      Rails.logger.warn "#{self.class}.results_with_params: terms passed in but filter_by not implemented."
    end

    rel = yield rel if block_given?
    rel = rel.where(opts[:where])

    if results_with_params_options[:wants_relation] || params[:wants_relation] == "true"
      ret_val = rel
    elsif results_with_params_options[:wants_full_array] || params[:show_all] == "true"
      ret_val = rel.klass.to_full_a(rel) { |rel2| rel2.paginate(page: params[:page]).tap { |r| set_total_count(r) }; rel2 }
    else
      ret_val = rel.paginate(page: params[:page], per_page: params[:per_page] || 30).tap { |r| set_total_count(r) }
    end

    ret_val
  end

  def set_total_count(rel)
    # HACK ATTACK!!!
    # Right now if we have a query that returns non-distinct results, the total count is off.
    # So if we are joining with tables that result in multiple records returned (e.g. zips->locations->cities)
    # per entity, the count will be off because the will paginate total_entries will find the total number of row
    # withouth distincting it.
    #
    # Refer to http://mantis.elocal.com/bug_view_page.php?bug_id=335 for the bug that caused me
    # to see what caused me to find this issue
    count = rel.except(:order, :limit, :offset).calculate(:count, "distinct #{rel.klass.table_name}.id")
    @total_count = number_with_delimiter(count.is_a?(Hash) ? count.values.sum : count)
  end
end

class ActionController::Base
  include ResultsWithParams
end
