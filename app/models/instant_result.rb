# encoding: utf-8
# an @ match
class InstantResult < ActiveRecord::Base
  attr_accessible :bang_match, :query
  belongs_to :query
end
