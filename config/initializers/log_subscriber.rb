module ActionView
  class LogSubscriber
    def render_template(event)
      message = "Rendered #{from_rails_root(event.payload[:identifier])}"
      message << " within #{from_rails_root(event.payload[:layout])}" if event.payload[:layout]
      message << (" (%.1fms)" % event.duration)
      debug(message)
    end
    alias :render_partial :render_template
    alias :render_collection :render_template
  end
end