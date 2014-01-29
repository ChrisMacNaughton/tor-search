# encoding: utf-8

require 'spec_helper'

describe Ad do

  fixtures :ads

  before(:each) do
    @ad = ads(:non_onion_ad)
  end

  it 'can determine if it is an onion address' do
    @ad.onion.should be_false

    @ad.path = '234567qwerdfghbn.onion'
    @ad.save

    @ad.onion.should be_true
  end

  it 'describes it\'s protocol correctly' do
    @ad.protocol.should eq 'http://'

    @ad.protocol_id = Ad::PROTOCOL_ID_HTTPS

    @ad.protocol.should eq 'https://'
  end

  it 'can determine its ClickThroughRate' do
    query = Query.create!(term: 'testing')
    search = Search.create!(query: query, results_count: 2, paginated: false)
    AdView.create!(ad_id: @ad.id, query_id: query.id, position: 1)
    AdView.create!(ad_id: @ad.id, query_id: query.id, position: 1)
    AdClick.create!(ad_id: @ad.id, query_id: query.id, search_id: search.id)

    @ad.reload
    @ad.ctr.should eq 50.0
  end

  it 'can determins its average position' do
    query = Query.create!(term: 'testing')
    AdView.create!(ad_id: @ad.id, query_id: query.id, position: 1)
    AdView.create!(ad_id: @ad.id, query_id: query.id, position: 3)

    @ad.reload
    @ad.avg_position.should eq 2.0
  end

  it 'returns 0 when there are no views' do
    @ad.ad_views_count.should eq 0
    @ad.ctr.should eq 0
  end
end
