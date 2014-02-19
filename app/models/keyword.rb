# encoding: utf-8
# a keyword that can match a search
class Keyword < ActiveRecord::Base
  attr_accessible :word, :searches_counts, :status_id

  STATUS_IDS = [0,1,2]
  STATUS_NEGATIVE = 0
  STATUS_STATIC = 1
  STATUS_POSITIVE = 2

end
