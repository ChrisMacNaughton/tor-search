class AdGroup < ActiveRecord::Base
  belongs_to :ad_campaign
  belongs_to :advertiser
  has_many :ad_group_keywords
  has_many :ads
  attr_accessible :name, :paused, :advertiser, :advertiser_id, :ad_campaign, :ad_campaign_id

  scope :without_keywords,
    where("NOT EXISTS (select 'x' FROM ad_group_keywords WHERE ad_group_id = ad_groups.id LIMIT 1)")

  def clicks_count
    ads.sum(&:ad_clicks_count)
  end

  def views_count
    ads.sum(&:ad_views_count)
  end

  def ctr
    if views_count > 0
      clicks_count / views_count.to_f
    else
      0
    end
  end

  def avg_position
    if @average_position.nil?
      if views_count > 0
        sum = 0
        ads.each do |ad|
          sum += ad.ad_views.sum(:position)
        end
        @average_position = sum / views_count.to_f
      else
        @average_position = 0
      end
    end
    @average_position
  end

end
