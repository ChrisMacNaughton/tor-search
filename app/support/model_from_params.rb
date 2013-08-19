module ModelFromParams
  #
  # Including classes need to define methods
  #  - params
  #  - associated_model_name
  #
  protected

  def lookup_object
    @lookup_object ||= with_includes(associated_model.where(id: params[:id])).first
  end

  def filtered_objects
    @filtered_objects ||= with_pagination(with_sorting(with_filters(with_includes(associated_model.scoped))))
  end

  def with_pagination(rel)
    rel.page(current_page).per_page(per_page)
  end

  def with_sorting(rel)
    allowed_filter_columns.each do |param_name|
      if params[:search][:advanced][param_name].present?
        if associated_model.respond_to?(:"with_#{param_name}")
          rel = rel.send(:"with_#{param_name}", params[:search][:advanced][param_name])
        else
          rel = rel.where({param_name.to_sym => params[:search][:advanced][param_name]})
        end
      end
    end

    rel
  end

  def with_filters(rel)
    if filter_sort_col.present?
      if associated_model.respond_to?(:"filter_by_#{filter_sort_col}")
        rel = rel.send(:"filter_by_#{filter_sort_col}", filter_sort_direction)
      else
        rel = rel.order("#{filter_sort_col} #{filter_sort_direction}")
      end
    end
    rel
  end

  def with_includes(rel)
    rel
  end
  def with_select(rel)
    rel
  end
  def per_page
    @per_page ||= (params[:per_page] || 10).to_i
  end

  def current_page
    @current_page ||= (params[:page] || 1).to_i
  end

  def allowed_sort_columns
    associated_model_columns
  end

  def allowed_filter_columns
    associated_model_columns
  end

  def associated_model
    @associated_model ||= associated_model_name.camelize.constantize
  end

  def associated_model_columns
    @associated_model_columns ||= associated_model.columns.map(&:name)
  end

  def filter_sort_col
    if params[:sort] && params[:sort][:key] && allowed_sort_columns.include?(params[:sort][:key])
      params[:sort][:key]
    else
      nil
    end
  end

  def filter_sort_direction
    if params[:sort] && params[:sort][:direction] && ['asc','desc'].include?(params[:sort][:direction])
      params[:sort][:direction]
    else
      ''
    end
  end
end