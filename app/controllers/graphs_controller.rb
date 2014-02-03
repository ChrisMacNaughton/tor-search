# encoding: utf-8
class GraphsController < ApplicationController
  def index
    track
  end

  def daily
    data = read_through_cache("weekly_searches", 1.day) do
      days = {}

      beginning = DateTime.parse('2013-09-12 00:00:00 UTC')

      ((DateTime.now - beginning).to_i).times do |i|
        wk = beginning + i.days
        rel = read_through_cache("searches_by_day_#{wk.strftime('%m/%d/%Y')}", 100.years) do
          Search \
            .where(created_at: ((wk-3.day).. (wk + 3.day) )) \
            .count(:id) / 7.0
        end
        days[(beginning + i.days).strftime('%m/%d/%Y')] = rel
      end

      #binding.pry
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

    beginning = DateTime.parse('2013-09-12 00:00:00 UTC')
    weeks = (DateTime.now - beginning).to_i
    searches_raw.keys.each_with_index do |date, index|
      puts index
      g.labels[index] = date if index % 28 == 0
      searches << searches_raw[date]
    end

    g.hide_title = true
    g.data :Searches, searches.reverse
    g.minimum_value = 0
    g.hide_dots = true

    g
  end
  # rubocop:enable MethodLength
end
