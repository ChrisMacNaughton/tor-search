module ApplicationHelper
  def nav_link(link_text, link_path, base_class = "")
    class_name = current_page?(link_path) ? 'active' : ''
    class_name = "#{base_class} #{class_name}"
    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end
end
class AppFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::OutputSafetyHelper
  include ::ApplicationHelper
  alias :orig_label :label

  def errors_for(object, wrap_in_div=true, use_full_messages=true)
    return "" if object.nil? || object.errors.blank?

    error_list = "".html_safe
    if use_full_messages
      object.errors.full_messages.each_with_index do |error_message, i|
        css_class = "formErrorMessage #{(object.errors.full_messages[-1] == error_message) ? 'last ' : ''}"
        error_list << content_tag('h5', error_message, class: css_class)
      end
    else
      error_keys = object.errors.messages.keys.reject{|k| object.errors.messages[k].empty?}
      error_keys.each_with_index do |key, i|
        css_class = "formErrorMessage #{(error_keys[-1] == key) ? 'last ' : ''}"
        error_list << content_tag('h5', object.errors.messages[key].first, class: css_class)
      end
    end
    if wrap_in_div
      e_message = content_tag(:h5, pluralize_sentence(object.errors.count, "error_count"), class: 'title')
      content_tag('div', e_message + error_list, class: 'formErrorList')
    else
      content_tag('div', error_list, class: 'error-class')
    end
  end

  def label(method, text = nil, options = {}, &block)
    # If the field is required then add an indicator.
    if text.blank?
      text = method.to_s.humanize.titleize
    end

    # specify only the class 'required' or append 'required' to the list of specified class names
    if required_field?(method)
      text = raw "#{text} *"
      options[:class] = options.has_key?(:class) ? "#{options[:class]} required" : "required"
    end

    orig_label(method, text, options, &block)
  end

  # Because Ruby interprets %m/%d/%Y as %d/%m/%Y for ambiguous dates, we create a hidden field containing an acceptable
  # date format and a text field for the display value.
  def date_picker(method, options = {})
    options[:class] ||= ""
    options[:class] += " datePicker"
    options[:data] ||= {}
    options[:data][:action] = "bindDate"
    options[:data][:target] = "##{object.class.to_s.underscore}_#{method}"
    options[:data][:attr] = "value"

    date = object.send(method)
    # We might have a date or a date/time. If it's a date/time, convert to UTC then convert to date.
    # Otherwise, if the time is midnight, it may appear later as the previous day.
    if date.respond_to? :utc
      date = object.send(method).utc.to_date
    end
    hidden_field(method, value: date) + "\n" +
        text_field_tag("_#{object.class.to_s.underscore}_#{method}", date.try(:strftime, "%m/%d/%Y"), options)
  end

  def current_nested_child_index(child_name)
    @nested_child_index["#{object_name}[#{child_name}_attributes]"]
  end

  def hours_select(method, options = {}, html_options = {})
    hours = [12, (1..11).to_a].flatten
    minutes = [ 0, 30 ]
    ampm = options.delete(:ampm) == false ? [""] : ["AM", "PM"]
    times = []
    pad2 = "%02d"

    ampm.each do |am_or_pm|
      hours.each do |hour|
        minutes.each do |minute|
          times << "#{pad2 % hour}:#{pad2 % minute} #{am_or_pm}"
        end
      end
    end
    select(method, times, options.merge(data: { value: options[:value] }), html_options)
  end

  private

  def required_field?(method)
    return unless @object
    @object.class.validators.any? do |v|
      v.is_a?(ActiveModel::Validations::PresenceValidator) && v.attributes.include?(method)
    end
  end
end
class WithErrorFields < AppFormBuilder
  def field_with_error(field, *args)
    if object.errors[args.first].present?
      send(field, *args) +
        content_tag(:span, object.errors[args.first][0], class: "error_mesg")
    else
      send(field, *args)
    end
  end

  def text_field_with_error(method, opts={})
    field_with_error :text_field, method, opts
  end
  def text_area_with_error(method, opts={})
    field_with_error :text_area, method, opts
  end
  def select_with_error(method, opts={})
    field_with_error :select, method, opts
  end

  def check_box_with_error(method, opts={})
    field_with_error :check_box, method, opts
  end

  def collection_chzn_with_error(method, collection, an_id, a_name, opts={})
    field_with_error :collection_select, method, collection, an_id, a_name, opts, class: "chzn-select"
  end

  def collection_select_with_error(method, collection, an_id, a_name, opts={})
    field_with_error :collection_select, method, collection, an_id, a_name, opts
  end

  def label_with_error(method, opts={})
    field_with_error :label, method, opts
  end
end