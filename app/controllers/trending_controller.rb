class TrendingController < ApplicationController
  def index
  end

  def search

  end

  def search_graph
    keywords = params[:q].map{|q|q.downcase.strip}.reject(&:empty?)

    g = Gruff::Line.new('600x200')

    g.title = "Searches for #{keywords.join(', ')}"

    #g.theme_greyscale
    start = DateTime.parse('September 1, 2013').to_date
    months = ((Date.today - start).to_f / 30).to_i + 1
    labels = []
    months.times do |i|
      labels << (start + i.months)
    end
    g.labels = {}
    g.hide_legend = false
    g.maximum_value = 1
    g.minimum_value = 0
    g.hide_dots = true

    keywords.each do |keyword|
      searches_data = []
      searches = Search.joins(:query) \
        .where('lower(term) like ?', "%#{keyword}%") \
        .group("to_char(searches.created_at, 'YYYY-MM')") \
        .order("to_char(searches.created_at, 'YYYY-MM')").count


      labels.each_with_index do |date, index|
        d = date.strftime('%Y-%m')
        g.labels[index] = date.strftime('%b %Y')
        searches_data << searches[d]
      end

      g.data(keyword.titleize, searches_data)
    end


    data = g.to_blob('PNG')
    #end
    send_data data, type: 'image/png', disposition: :inline
  end
end
