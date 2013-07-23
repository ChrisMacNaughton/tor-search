class Click < ActiveRecord::Base
  belongs_to :search, counter_cache: true
  belongs_to :page
  attr_accessible :search, :page
end
