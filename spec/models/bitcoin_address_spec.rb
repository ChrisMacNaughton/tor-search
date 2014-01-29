# encoding: utf-8

require 'spec_helper'

describe BitcoinAddress do

  fixtures :bitcoin_addresses

  it 'returns its address when to_s is called' do
    bitcoin_addresses(:address_1).to_s.should eq 'oq34ygfbsfky0o4gwey'
  end
end
