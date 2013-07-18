class FlagReason < ActiveRecord::Base
  has_many :content_flags
  attr_accessible :description
end
