class Ad < ActiveRecord::Base
  class AdMinimumBidValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record.ppc?
        record.errors.add(:bid, options[:message] || "must be greater than  or equal to 0.005 BTC") \
          if record.bid < 0.005
      else
        record.errors.add(:bid, options[:message] || "must be greater than  or equal to 0.0001 BTC") \
          if record.bid < 0.0001
      end
    end
  end
  belongs_to :advertiser
  has_many :ad_views
  has_many :ad_clicks
  attr_accessible :bid, :body, :title, :disabled, :path, :approved
  validates :path, presence: true
  validates :title, presence: true
  validates :body, presence: true
  validates :bid, presence: true, ad_minimum_bid: true
  before_save :check_onion
  scope :available, -> {
    where(approved: true).where(disabled: false)
  }
  def check_onion
    check_path = self.path.gsub(/https?:\/\//, '')
    self.onion = !!(check_path =~ /^.{16}\.onion/)
    true
  end
  def ctr
    ad_clicks_count / ad_views_count.to_f * 100
  end
  def avg_position
    @sum ||= ad_views.average(:position)
  end
end
