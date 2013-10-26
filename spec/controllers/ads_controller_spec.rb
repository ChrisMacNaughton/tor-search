# encoding: utf-8

require 'spec_helper'
include Devise::TestHelpers

describe AdsController do
  before(:each) do
    @advertiser = advertisers(:test_advertiser)
    sign_in @advertiser
  end
  fixtures :ads, :advertisers

  describe 'bitcoin addresses' do

    it 'can request a new bitcoin address' do
      @advertiser.bitcoin_addresses.count.should eq 0
      VCR.use_cassette "get-a-single-bitcoin-address" do
        get :get_payment_address

        @advertiser.bitcoin_addresses.count.should eq 1
      end
    end

    it 'only requests one new bitcoin address in 6 hours' do
      @advertiser.bitcoin_addresses.count.should eq 0
      VCR.use_cassette "get-first-bitcoin-address" do
        get :get_payment_address
      end
      get :get_payment_address

      @advertiser.bitcoin_addresses.count.should eq 1
    end
  end

  it 'allows advertisers to request beta access' do
    request.env["HTTP_REFERER"] = '/ads'
    put :request_beta, {id: @advertiser.id}
    @advertiser.reload
    @advertiser.wants_beta.should be_true
  end

  describe 'managing ads' do

    it 'can create a new ad' do
      @advertiser.ads.count.should eq 2
      post :create, {ad: {title: 'test ad', path: 'google.com', bid: 0.05, protocol_id: 1}}
      response.status.should == 302
      #@advertiser.reload
      @advertiser.ads.count.should eq 3
    end

    it 'can edit an ad' do
      ad = ads(:ad)
      ad.title.should eq 'This is an ad'
      put :update, {id: ad.id, ad: {title: 'something else'}}
      ad.reload
      ad.title.should eq 'something else'
    end

    it 'can toggle an ad\'s status' do
      ad = ads(:ad)
      put :toggle, {id: ad.id}

      ad.reload
      ad.disabled.should eq true
    end

  end

end
