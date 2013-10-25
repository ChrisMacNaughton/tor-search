# encoding: utf-8
# clicking on a search result is trackedd
class Click < ActiveRecord::Base
  belongs_to :search, counter_cache: true
  belongs_to :page
  attr_accessible :search, :target
end
