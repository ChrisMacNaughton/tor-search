# encoding: utf-8

require 'spec_helper'

describe BitcoinAddressSerializer do

  it 'returns its address when to_s is called' do
    advertiser = Advertiser.create!(username: 'tester', password:'test1234',password_confirmation: 'test1234')
    address = BitcoinAddress.create!
    Payment.create!(bitcoin_address: address, advertiser: advertiser, amount: 1.0)
    address = BitcoinAddressSerializer.new address

    address.balance.should eq 1.0

  end
end
