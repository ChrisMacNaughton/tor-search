class Ad < ActiveRecord::Base
  class AdMinimumBidValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(:bid, options[:message] || "must be greater than  or equal to 0.005 BTC") \
        if record.bid < 0.005
    end
  end
  PROTOCOL_ID_HTTP = 0
  PROTOCOL_ID_HTTPS = 1
  PROTOCOL_IDS = [PROTOCOL_ID_HTTPS,PROTOCOL_ID_HTTP]

  belongs_to :advertiser
  has_many :ad_views
  has_many :ad_clicks
  has_many :ad_keywords
  accepts_nested_attributes_for :ad_keywords
  has_many :keywords, through: :ad_keywords
  attr_accessible :bid, :title, :disabled, :protocol_id, :path, :approved,
    :ppc, :display_path, :line_1, :line_2, :category_id, :include_path, :advertiser
  validates :path, presence: true
  validates :title, presence: true
  validates :bid, presence: true, ad_minimum_bid: true
  validates :protocol_id, inclusion: { in: PROTOCOL_IDS}
  before_save :check_onion
  scope :available, -> {
    where(approved: true).where(disabled: false)
  }
  attr_accessor :include_path
  def check_onion
    check_path = self.path.gsub(/https?:\/\//, '')
    self.onion = !!(check_path =~ /^.{16}\.onion/)
    true
  end
  def protocol
    if protocol_id == PROTOCOL_ID_HTTP
      "http://"
    elsif protocol_id == PROTOCOL_ID_HTTPS
      "https://"
    end
  end
  def ctr
    ad_clicks_count / ad_views_count.to_f * 100
  end
  def avg_position
    @sum ||= ad_views.average(:position)
  end
end
