class GraphsController < ApplicationController
  def index
  end
  def daily
    g = Gruff::Bar.new('500x150')
    g.title = 'Searches By Day'
    g.theme_greyscale
    g.labels = {}
    g.hide_legend = true
    searches = []
    searches_raw = Search.group("to_char(created_at, 'MM/DD/YYYY')").where("created_at > ?", 31.days.ago).count
    30.times do |i|
      date = (i+1).days.ago
      g.labels[29 - i] = date.to_datetime.strftime('%m/%d') if i % 3 == 0
     s = searches_raw[date.strftime('%m/%d/%Y')]
     s ||= 0
      searches << s
    end
    g.hide_title = true
    g.data :Searches, searches.reverse

    send_data g.to_blob('PNG'), :type => "image/png", disposition: :inline
  end
  def unique
    g = Gruff::Bar.new('500x150')
    g.title = 'Searches By Day'
    g.theme_greyscale
    g.labels = {}
    g.hide_legend = true
    searches = []
    searches_raw = Search.group("to_char(created_at, 'MM/DD/YYYY')").where("created_at > ?", 31.days.ago).count(select: 'distinct(query_id)')
    30.times do |i|
      date = (i+1).days.ago
      g.labels[29 - i] = date.to_datetime.strftime('%m/%d') if i % 3 == 0
      s = searches_raw[date.strftime('%m/%d/%Y')]
      s ||= 0
      searches << s
    end
    g.hide_title = true
    g.data :Searches, searches.reverse

    send_data g.to_blob('PNG'), :type => "image/png", disposition: :inline
  end
end
