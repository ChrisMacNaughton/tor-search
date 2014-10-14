# encoding: utf-8
class GraphsController < ApplicationController
  def index
    track
  end

  def daily
    #data = read_through_cache("daily_searches", 2.hours) do
    days = {}

    beginning = DateTime.parse('2013-09-12 00:00:00 UTC')

    ((3.days.ago - beginning) / 60 / 60/ 24).to_i.times do |i|
      wk = beginning + i.days
      count = read_through_cache("searches_by_day_#{wk.strftime('%m/%d/%Y')}", 365.days) do
        Search \
          .where(created_at: ((wk-3.days)..(wk + 3.days) )) \
          .count(:id) / 7.0
      end
      days[wk.strftime('%m/%d/%Y')] = count
    end

    #binding.pry
    g = build_graph 'Searches By Week', days.reject{|k,v| v.nil? }

    data = g.to_blob('PNG')
    #end
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

    searches_raw.keys.each_with_index do |date, index|
      g.labels[index] = if index % 90 == 0
        date
      else
        nil
      end
      searches << searches_raw[date]
    end

    g.hide_title = true
    g.data :Searches, searches
    g.minimum_value = 0
    g.hide_dots = true

    g
  end
  # rubocop:enable MethodLength
end
