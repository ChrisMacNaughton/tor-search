# encoding: utf-8

# a unique search query
class Query < ActiveRecord::Base
  attr_accessible :term

  has_many :searches
  validates :term, uniqueness: true

end
