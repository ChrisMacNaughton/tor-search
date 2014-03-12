# encoding: utf-8
require 'spec_helper'
describe AdFinder do

  fixtures :ads, :ad_groups, :ad_campaigns, :keywords, :advertisers

  it 'can find an ad with no keywords' do
    finder = AdFinder.new('test')
    finder.ads.should include ads(:ad)
  end

  it 'can find an ad by keyword' do
    ad = ads(:ad)
    keyword = keywords(:otherwise)
    ad.ad_group.ad_group_keywords.create(keyword: keyword, bid: 0.01)

    AdFinder.new('test').ads.should_not include ad
    AdFinder.new('otherwise').ads.should include ad
  end

  it 'ranks ads appropriately' do
    ads(:non_onion_ad).ad_group.update_attribute(:paused, false)
    ads(:ad).update_attribute(:disabled, false)
    ads = AdFinder.new('whatever').ads
    ads.should == [ads(:non_onion_ad), ads(:ad)]
  end

end
