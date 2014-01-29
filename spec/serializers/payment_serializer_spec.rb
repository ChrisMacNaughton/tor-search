# encoding: utf-8

require 'spec_helper'

describe PaymentSerializer do
  fixtures :coupons, :advertisers, :bitcoin_addresses
  context 'a coupon payment' do
    before(:each) do
      @serializer = PaymentSerializer.new Payment.create!(coupon: coupons(:half_btc), advertiser: advertisers(:test_advertiser_2))
    end
    it 'can show its coupon code' do
      @serializer.coupon_code.should eq coupons(:half_btc).code
    end

    it 'does not fail when calling bitcoin address' do
      @serializer.bitcoin_address.should be_nil
    end
  end

  context 'a bitcoin payment' do
    before(:each) do
      @serializer = PaymentSerializer.new Payment.create!(bitcoin_address: bitcoin_addresses(:address_2), advertiser: advertisers(:test_advertiser_2))
    end
    it 'can show its payment address' do
      @serializer.bitcoin_address.should eq bitcoin_addresses(:address_2).address
    end

    it 'does not explode when calling coupon code' do
      @serializer.coupon_code.should be_nil
    end
  end
end
