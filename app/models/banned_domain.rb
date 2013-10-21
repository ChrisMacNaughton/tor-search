class BannedDomain < ActiveRecord::Base
  validates :hostname, presence: true
  validates :hostname, uniqueness: true

  attr_accessible :hostname, :reason
end
