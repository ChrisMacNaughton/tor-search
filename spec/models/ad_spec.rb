require 'spec_helper'

describe Ad do
  fixtures :ads
  before(:each) do
    @ad = ads(:non_onion_ad)
  end
  it "can determine if it is an onion address" do
    @ad.onion.should be_false

    @ad.path = "234567qwerdfghbn.onion"
    @ad.save

    @ad.onion.should be_true
  end
  it "describes it's protocol correctly" do
    @ad.protocol.should == "http://"

    @ad.protocol_id = Ad::PROTOCOL_ID_HTTPS

    @ad.protocol.should == "https://"
  end
end
