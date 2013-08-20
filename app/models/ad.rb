class Ad < ActiveRecord::Base
  belongs_to :advertiser
  has_many :ad_views
  has_many :ad_clicks
  attr_accessible :bid, :body, :title, :disabled, :path, :approved
  validates :path, presence: true
  validates :title, presence: true
  validates :body, presence: true
  before_save :check_onion
  scope :available, -> {
    where(approved: true).where(disabled: false)
  }

  def check_onion
    check_path = self.path.gsub(/https?:\/\//, '')
    self.onion = !!(check_path =~ /^.{16}\.onion/)
    true
  end
end
