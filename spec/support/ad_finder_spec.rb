# encoding: utf-8
require 'spec_helper'
describe AdFinder do

  fixtures :ads, :keywords

  it 'can find an ad with no keywords' do
    finder = AdFinder.new('test')
    finder.ads.should include ads(:ad)
  end

  it 'can find an ad by keyword' do
    ad = ads(:ad)
    ad.keywords << keywords(:otherwise)

    AdFinder.new('test').ads.should_not include ad
    AdFinder.new('otherwise').ads.should include ad
  end

  it 'ranks ads appropriately' do
    ads = AdFinder.new('whatever').ads
    ads.should == [ads(:non_onion_ad), ads(:ad)]
  end

end
