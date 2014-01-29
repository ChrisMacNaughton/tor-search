# encoding: utf-8

require 'spec_helper'

describe AdKeywordSerializer do

  fixtures :ad_keywords, :ads, :keywords

  it 'returns its ads title' do
    serializer = AdKeywordSerializer.new ad_keywords(:ad_keyword_1)
    serializer.ad_title.should eq 'This is a test ad'

  end
end
