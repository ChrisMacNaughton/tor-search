# encoding: utf-8
# a specific ad that can be shown
class Ad < ActiveRecord::Base
  PROTOCOL_ID_HTTP = 0
  PROTOCOL_ID_HTTPS = 1
  PROTOCOL_IDS = [PROTOCOL_ID_HTTPS , PROTOCOL_ID_HTTP]

  belongs_to :advertiser
  has_many :ad_views
  has_many :ad_clicks
  has_many :ad_keywords
  accepts_nested_attributes_for :ad_keywords
  has_many :keywords, through: :ad_keywords

  # keyword_id is for tracking an ad selected from a keyword
  # include_path is for auto generated ads to know their path with the redirect
  attr_accessible :bid, :title, :disabled, :protocol_id, :path, :approved,
                  :ppc, :display_path, :line_1, :line_2, :include_path,
                  :advertiser
  validates :advertiser_id, presence: true
  validates :path, presence: true
  validates :title, presence: true
  validates :bid, presence: true
  validates :protocol_id, inclusion: { in: PROTOCOL_IDS }
  before_save :check_onion
  scope :available, lambda {
    where(approved: true).where(disabled: false)
  }
  attr_accessor :include_path, :keyword_id

  def check_onion
    check_path = path.gsub(%r(https?://), '')
    self.onion = !!(check_path =~ /^[2-7a-zA-Z]{16}\.onion/)
    true
  end

  def protocol
    if protocol_id == PROTOCOL_ID_HTTP
      'http://'
    elsif protocol_id == PROTOCOL_ID_HTTPS
      'https://'
    end
  end

  def ctr
    if ad_views_count > 0
      ad_clicks_count / ad_views_count.to_f * 100
    else
      0
    end
  end

  def avg_position
    @sum ||= ad_views.average(:position)
  end
end
