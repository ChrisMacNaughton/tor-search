# encoding: utf-8
# A single search
class Search < ActiveRecord::Base
  include SearchByKeyedScopes
  attr_accessible :query, :results_count, :paginated
  has_many :clicks
  belongs_to :query, counter_cache: true

end
