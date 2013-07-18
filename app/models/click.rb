class Click < ActiveRecord::Base
  belongs_to :search
  belongs_to :page
  attr_accessible :search, :page
end
