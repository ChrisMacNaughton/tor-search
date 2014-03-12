# encoding: utf-8

require 'spec_helper'

describe SearchController do
  include Devise::TestHelpers
  fixtures :ads, :ad_groups, :ad_campaigns, :advertisers, :keywords

  describe 'index' do

    it 'tracks a user'

    it 'gets the total indexed count from Solr'

  end

  describe 'a search' do

    it 'credits an ad with views' do
      VCR.use_cassette('search-for-testing') do
        get :index, { q: 'testing' }
        response.status.should == 200
      end
      ad = ads(:ad)
      ad.ad_views.count.should == 1
    end

    it 'charges an account for a click' do
      ad = ads(:ad)
      balance = ad.advertiser.balance
      post :ad_redirect, { id: ad.id }
      advertiser = advertisers(:test_advertiser)
      advertiser.balance.should == balance - ad.bid
    end

    it 'charges an account for a click on an ad with a keyword' do
      ad = ads(:ad)
      keyword = keywords(:otherwise)
      k = ad.ad_group.ad_group_keywords.create(keyword: keyword, bid: 0.01)
      balance = ad.advertiser.balance
      post :ad_redirect, { id: ad.id, k: keyword.id }
      advertiser = advertisers(:test_advertiser)
      advertiser.balance.should == balance - k.bid
    end

  end

end
