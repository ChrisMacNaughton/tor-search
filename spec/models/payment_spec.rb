require 'spec_helper'

describe Payment do

  fixtures :bitcoin_addresses, :advertisers, :coupons

  before(:each) do
    @advertiser = advertisers(:test_advertiser)
    @address = bitcoin_addresses(:address_1)
    @coupon = coupons(:half_btc)
  end

  it "credits an advertiser when a bitcoin address receives a payment" do
    @advertiser.balance.should == 0.5

    Payment.create(transaction_hash: '123456', bitcoin_address: @address, advertiser: @advertiser, amount: 0.5)

    @advertiser.balance.should == 1.0
  end

  it "credits an advertiser when a coupon is applied" do
    @advertiser.balance.should == 0.5

    Payment.create(advertiser: @advertiser, coupon: @coupon, amount: @coupon.value)

    @advertiser.balance.should == 1.0
  end

  it "cannot receive the same coupon twice" do
    @advertiser.balance.should == 0.5

    Payment.create(advertiser: @advertiser, coupon: @coupon, amount: @coupon.value)

    @advertiser.balance.should == 1.0

    Payment.create(advertiser: @advertiser, coupon: @coupon, amount: @coupon.value)

    @advertiser.balance.should == 1.0
  end

end
