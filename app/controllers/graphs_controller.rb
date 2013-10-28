# encoding: utf-8
class GraphsController < ApplicationController
  def index
    track
  end

  def daily
    rel = read_through_cache('searches_by_day', 2.hours) do
      Search \
      .group("to_char(created_at, 'MM/DD/YYYY')") \
      .where('created_at > ?', 31.days.ago.to_date).count
    end
    g = build_graph 'Searches By Day', rel

    send_data g.to_blob('PNG'), type: 'image/png', disposition: :inline
  end

  def unique
    rel = read_through_cache('unique_searches_by_day', 2.hours) do
      Search \
      .group("to_char(created_at, 'MM/DD/YYYY')") \
      .where('created_at > ?', 31.days.ago.to_date).count(select: 'distinct(query_id)')
    end
    g = build_graph 'Unique Searches By Day', rel

    send_data g.to_blob('PNG'), type: 'image/png', disposition: :inline
  end

  private

  # rubocop:disable MethodLength
  def build_graph(title, searches_raw)

    g = Gruff::Bar.new('500x150')
    g.title = title

    g.theme_greyscale
    g.labels = {}
    g.hide_legend = true
    searches = []

    30.times do |i|
      date = (i + 1).days.ago
      g.labels[29 - i] = date.to_datetime.strftime('%m/%d') if i % 3 == 0
     s = searches_raw[date.strftime('%m/%d/%Y')]
     s ||= 0
      searches << s
    end
    g.hide_title = true
    g.data :Searches, searches.reverse

    g
  end
  # rubocop:enable MethodLength
end
