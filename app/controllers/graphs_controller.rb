# encoding: utf-8
class GraphsController < ApplicationController
  def index
    track
  end

  def daily
    data = read_through_cache("weekly_searches", 1.day) do
      days = {}
      weeks = (DateTime.now - DateTime.parse('2013-09-12 15:25:27 UTC')).to_i / 7
      (1..weeks).each do |i|
        rel = read_through_cache("searches_by_day_#{i.weeks.ago.strftime('%m/%d/%Y')}", 100.years) do
          Search \
            .where(created_at: (i.weeks.ago.. (i.weeks.ago + 7.days) )) \
            .count(:id) / 7.0
        end
        days[i.weeks.ago.strftime('%m/%d/%Y')] = rel
      end
      g = build_graph 'Searches By Week', days.reject{|k,v| v.nil? }

      g.to_blob('PNG')
    end
    send_data data, type: 'image/png', disposition: :inline
  end

  private

  # rubocop:disable MethodLength
  def build_graph(title, searches_raw)

    g = Gruff::Line.new('500x150')
    g.title = title

    g.theme_greyscale
    g.labels = {}
    g.hide_legend = true
    searches = []
    i = 0
    weeks = (DateTime.now - DateTime.parse('2013-09-12 15:25:27 UTC')).to_i / 7

    weeks.times do |i|
      date = (i + 1).weeks.ago
      g.labels[weeks - i] = date.to_datetime.strftime('%m/%Y') if i % 4 == 0
       s = searches_raw[date.strftime('%m/%d/%Y')]
       s ||= 0
      searches << s
    end
    g.hide_title = true
    g.data :Searches, searches.reverse
    g.minimum_value = 0
    g.hide_dots = true

    g.reference_lines[1] = {index: 100}
    g
  end
  # rubocop:enable MethodLength
end
