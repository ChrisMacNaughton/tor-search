# encoding: utf-8
require 'spec_helper'
require 'matcher/matcher'
require 'webmock/rspec'
describe Matcher do
  context 'bitcoin matcher' do

    it 'matches btc' do
      VCR.use_cassette('get_bitcoin_prices') do
        matches = Matcher.new('btc', OpenStruct.new({})).execute
        matches.length.should eq 1
        btc = matches.first

        btc[:name].should eq 'Bitcoin Prices'
        btc[:data][:usd].should eq '797.4766799999999'
        btc[:weight].should eq 10
      end
    end

    it 'matches bitcoins' do
      VCR.use_cassette('get_bitcoin_prices') do
        matches = Matcher.new('bitcoins', OpenStruct.new({})).execute
        matches.length.should eq 1
        btc = matches.first

        btc[:name].should eq 'Bitcoin Prices'
        btc[:data][:usd].should eq '797.4766799999999'
        btc[:weight].should eq 10
      end
    end

    it 'can return values for a specific currency' do
      VCR.use_cassette('get_bitcoin_prices') do
        matches = Matcher.new('btc eur', OpenStruct.new({})).execute
        matches.length.should eq 1

        btc = matches.first

        btc[:name].should eq 'Bitcoin Prices'
        btc[:data][:usd].should eq nil
        btc[:data][:eur].should eq '586.707581'
        btc[:weight].should eq 10
      end
    end

    it 'does not explode when we cannot communicate with coinbase' do
      stub_request(:get, 'https://coinbase.com/api/v1/currencies/exchange_rates').to_raise(Errno::ECONNREFUSED)
      matches = Matcher.new('btc', OpenStruct.new({})).execute
      matches.length.should eq 0
    end
  end

  context 'user agent matcher' do

    before(:all) do
      @request = OpenStruct.new(
          user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:24.0)',
          headers: HashWithIndifferentAccess.new(
              'SERVER_NAME' => 'elocal.dev',
              'REQUEST_METHOD' => 'GET',
              'REQUEST_URI' => '/',
              'HTTP_VERSION' => 'HTTP/1.1',
              'HTTP_HOST' => 'localhost:3000',
              'HTTP_ACCEPT' => 'text/html,application/xhtml+xml',
              'HTTP_ACCEPT_LANGUAGE' => 'en-US,en;q=0.5',
              'HTTP_ACCEPT_ENCODING' => 'gzip, deflate',
              'HTTP_CONNECTION' => 'keep-alive',
              'HTTP_CACHE_CONTROL' => 'max-age=0',
              'GATEWAY_INTERFACE' => 'CGI/1.2',
              'SERVER_PORT' => '3000',
              'QUERY_STRING' => '',
              'SERVER_PROTOCOL' => 'HTTP/1.1',
              'SCRIPT_NAME' => '',
              'REMOTE_ADDR' => '127.0.0.1'
          )
      )
    end

    ['useragent', 'user agent', 'header', 'request header'].each do |name|

      it 'matches #{name}' do
        matches = Matcher.new(name, @request).execute
        matches.length.should eq 1
        agent = matches.first
        agent[:name].should eq 'Request Headers'
        agent[:weight].should eq 15
      end

    end

  end

end
