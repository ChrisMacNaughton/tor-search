class AdGroupKeyword < ActiveRecord::Base
  belongs_to :ad_group
  belongs_to :keyword
  has_many :ads, through: :ad_group
  attr_accessible :ad_group_id, :ad_group, :keyword_id, :keyword, :bid
  validates :ad_group_id, uniqueness: { scope: [:keyword_id, :ad_group_id] }

  scope :valid,
    where('ad_group_keywords.bid <= advertisers.balance') \
    .joins(:ad_group) \
    .joins('LEFT JOIN advertisers ON advertisers.id = ad_groups.advertiser_id')

  def status
    if paused?
      "Paused"
    else
      "Active"
    end
  end

  def clicks
    AdClick.where(keyword_id: keyword_id).count
  end

  def views
    AdView.where(keyword_id: keyword_id).count
  end

  def ctr
    if views > 0
      clicks / views.to_f
    else
      0
    end * 100
  end

  def word
    keyword.word
  end
end