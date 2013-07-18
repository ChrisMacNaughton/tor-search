class RawContent < ActiveRecord::Base
  belongs_to :page
  attr_accessible :body, :page
end
