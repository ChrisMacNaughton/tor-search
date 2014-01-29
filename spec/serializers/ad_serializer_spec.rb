# encoding: utf-8

require 'spec_helper'

describe AdSerializer do

  fixtures :ads
  context "an http ad" do
    before(:each) do
      @ad_serializer = AdSerializer.new ads(:ad)
    end
    it 'returns its views count' do
      @ad_serializer.views.should eq 0
    end

    it 'returns its clicks count' do
      @ad_serializer.clicks.should eq 0
    end

    it 'returns its protocol as human readable' do
      @ad_serializer.protocol.should eq('HTTP')
    end

    it 'returns its status' do
      @ad_serializer.status.should == "Active"
    end
  end
  context 'a disabled https ad' do
    before(:each) do
      @ad_serializer = AdSerializer.new ads(:secure_ad)
    end
    it 'returns protocol correctly for https too' do
      @ad_serializer.protocol.should eq('HTTPS')
    end
    it 'shows that its paused' do
      @ad_serializer.status.should == "Paused"
    end
  end
  context 'an unapproved ad' do
    it 'knows it is pending' do
      ad_serializer = AdSerializer.new ads(:unapproved_ad)
      ad_serializer.status.should == "Pending"
    end
  end
end
