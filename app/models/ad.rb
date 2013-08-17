class Ad < ActiveRecord::Base
  belongs_to :advertiser
  attr_accessible :bid, :body, :title, :disabled, :path, :approved
  validates :path, presence: true
  validates :title, presence: true
  validates :body, presence: true

  scope :available, -> {
    where(approved: true)
  }
end
