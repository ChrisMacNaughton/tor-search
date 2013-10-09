class KeywordToolController < ApplicationController
  before_filter :track
  def index
    if params[:keyword]
      check
    end
  end
  def check
    if params[:keyword] == ''
      flash.alert = "You must enter a term"
      redirect_to :keyword_tool
    end
    words = params[:keyword].split(/\s/)
    query = "select
        coalesce(sum(searches_count.search_count),0) count, queries.term
        from queries
        left join (
          select count(*) search_count, query_id
          from searches
          where created_at > '#{30.days.ago.to_s(:db)}'
          group by query_id
        ) searches_count
      on searches_count.query_id = queries.id
      where upper(queries.term) like upper('%#{params[:keyword].gsub(/'/, "''")}%')"
      words.each{|w| query += " OR upper(queries.term) like upper('%#{w.gsub(/'/, "''")}%')"} if words.count > 1
      query += "
      group by queries.term
      order by count desc"
    res = Query.connection.execute(query).select{|h| h['count'].to_i > 0}
    @total = res.sum{|h| h['count'].to_i}
    @queries = res.take(10)
  end
end
