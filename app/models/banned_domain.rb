# encoding: utf-8
# creating a banned domain keeps it out of the search results

class BannedDomain < ActiveRecord::Base
  validates :hostname, presence: true
  validates :hostname, uniqueness: true

  attr_accessible :hostname, :reason
end
