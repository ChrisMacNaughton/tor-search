require "matcher/matcher"
describe Matcher do
  context "bitcoin matcher" do

    it "matches btc" do
      VCR.use_cassette('get_bitcoin_prices') do
        matches = Matcher.new("btc", OpenStruct.new({})).execute
        matches.length.should == 1
        btc = matches.first

        btc[:name].should == "Bitcoin Prices"
        btc[:data][:usd].should == "196.9272"
        btc[:weight].should == 10
      end
    end

    it "matches bitcoins" do
      VCR.use_cassette('get_bitcoin_prices') do
        matches = Matcher.new("bitcoins", OpenStruct.new({})).execute
        matches.length.should == 1
        btc = matches.first

        btc[:name].should == "Bitcoin Prices"
        btc[:data][:usd].should == "196.9272"
        btc[:weight].should == 10
      end
    end

    it "can return values for a specific currency"

  end

  context "user agent matcher" do

    before(:all) do
      @request = OpenStruct.new(
        {
          user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:24.0) Gecko/20100101 Firefox/24.0",
          headers: HashWithIndifferentAccess.new(
            {
              "SERVER_NAME"=>"elocal.dev",
              "REQUEST_METHOD"=>"GET",
              "REQUEST_URI"=>"/",
              "HTTP_VERSION"=>"HTTP/1.1",
              "HTTP_HOST"=>"localhost:3000",
              "HTTP_ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
              "HTTP_ACCEPT_LANGUAGE"=>"en-US,en;q=0.5",
              "HTTP_ACCEPT_ENCODING"=>"gzip, deflate",
              "HTTP_CONNECTION"=>"keep-alive",
              "HTTP_CACHE_CONTROL"=>"max-age=0",
              "GATEWAY_INTERFACE"=>"CGI/1.2",
              "SERVER_PORT"=>"3000",
              "QUERY_STRING"=>"",
              "SERVER_PROTOCOL"=>"HTTP/1.1",
              "SCRIPT_NAME"=>"",
              "REMOTE_ADDR"=>"127.0.0.1"
            }
          )
        }
      )
    end

    ['useragent', 'user agent', 'header','request header'].each do |name|

      it "matches #{name}" do
        matches = Matcher.new(name, @request).execute
        matches.length.should == 1
        agent = matches.first
        agent[:name].should == "Request Headers"
        agent[:weight].should == 15
      end

    end

  end

end