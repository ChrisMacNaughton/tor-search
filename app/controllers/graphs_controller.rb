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
    30.times do |i|
      date = (i+1).days.ago
      g.labels[29 - i] = date.to_datetime.strftime('%m/%d') if i % 3 == 0
      searches << Search.where("to_char(created_at, 'DD/MM/YYYY') = ?", date.to_date.strftime('%d/%m/%Y')).count
    end
    g.hide_title = true
    g.data :Searches, searches

    send_data g.to_blob('PNG'), :type => "image/png", disposition: :inline
  end
  def unique
    g = Gruff::Bar.new('500x150')
    g.title = 'Searches By Day'
    g.theme_greyscale
    g.labels = {}
    g.hide_legend = true
    searches = []
    30.times do |i|
      date = (i+1).days.ago
      g.labels[29 - i] = date.to_datetime.strftime('%m/%d') if i % 3 == 0
      searches << Search.count_by_sql("select count(distinct(searches.query_id)) from searches where to_char(created_at, 'DD/MM/YYYY') = '#{date.to_date.strftime('%d/%m/%Y')}'")
    end
    g.hide_title = true
    g.data :Searches, searches

    send_data g.to_blob('PNG'), :type => "image/png", disposition: :inline
  end
end
