# encoding: utf-8
class GraphsController < ApplicationController
  def index
    track
  end

  def daily
    days = {}
    (0..31).each do |i|
      rel = read_through_cache("searches_by_day_#{i.days.ago.strftime('%m/%d/%Y')}", (32 - i).days) do
        Search.group("to_char(created_at, 'MM/DD/YYYY')").where("to_char(created_at, 'YYYY-MM-DD') = ?", i.days.ago.to_date).count
      end
      days[i.days.ago.strftime('%m/%d/%Y')] = if rel && rel.first
        rel.first[-1]
      end
    end
    g = build_graph 'Searches By Day', days.reject{|k,v| v.nil? }

    send_data g.to_blob('PNG'), type: 'image/png', disposition: :inline
  end

  def unique
    days = {}
    (0..31).each do |i|
      rel = read_through_cache("unique_searches_by_day_#{i.days.ago.strftime('%m/%d/%Y')}", (32 - i).days) do
        Search \
          .group("to_char(created_at, 'MM/DD/YYYY')") \
          .where("to_char(created_at, 'YYYY-MM-DD') = ?", i.days.ago.to_date) \
          .count(select: 'distinct(query_id)')
      end
      days[i.days.ago.strftime('%m/%d/%Y')] = if rel && rel.first
        rel.first[-1]
      end
    end
    g = build_graph 'Searches By Day', days.reject{|k,v| v.nil? }

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
