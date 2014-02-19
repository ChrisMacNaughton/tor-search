class KeywordSupport
  class KeywordCountJob
    def initialize(keyword_id)
      @keyword_id = keyword_id
    end

    def perform
      keyword = Keyword.find(@keyword_id)
      keyword.update_keyword_counts!
    end
  end
end