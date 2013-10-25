# encoding: utf-8
# a keyword that can match a search
class Keyword < ActiveRecord::Base
  attr_accessible :word
end
