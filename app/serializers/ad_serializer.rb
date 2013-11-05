class AdSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :title, :bid, :status, :views, :clicks, :ctr, :avg_position, :protocol,
             :path, :display_path, :line_1, :line_2, :errors

  def views
    object.ad_views_count
  end

  def clicks
    object.ad_clicks_count
  end

  def protocol
    if object.protocol_id == 0
      "HTTP"
    else
      "HTTPS"
    end
  end

  def status
    if object.approved?
      if object.disabled?
        "Paused"
      else
        "Active"
      end
    else
      "Pending"
    end
  end

end
