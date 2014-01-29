# encoding: utf-8
require 'spec_helper'
require 'webmock/rspec'
describe SolrSearch do

  it 'can get the number of indexed docs' do
    VCR.use_cassette('get_solr_index_size') do
      search = SolrSearch.new

      search.indexed.should == 134_509
    end
  end

  it 'doesn\'t return banned domains in the search' do
    VCR.use_cassette('get_fresh_solr_search') do
      search = SolrSearch.new('test')
      host = search.records.first['host']
      BannedDomain.create!(hostname: host, reason: 'Testing!!!')
    end

    VCR.use_cassette('get_rejected_solr_search') do
      host2 = SolrSearch.new('test').records.first['host']
      host1 = BannedDomain.first.hostname
      host2.should_not == host1
    end
  end

  it 'can have its query set after initialization' do
    solr1 = SolrSearch.new
    solr2 = SolrSearch.new('test')

    solr1.query = 'test'
    VCR.use_cassette('test_multiple_solr_initializations') do
      solr1.records.should eq(solr2.records)
    end
  end

  it 'can have its page set after initialization' do
    solr1 = SolrSearch.new('test')
    solr2 = SolrSearch.new('test', 2)

    solr1.page = 2
    VCR.use_cassette('test_multiple_solr_initialization_pagination') do
      solr1.records.should eq(solr2.records)
    end
  end

  it 'knows how many results it returned' do
    solr = SolrSearch.new('test data')
    VCR.use_cassette('test-solr-totals') do
      solr.total.should eq(52)
    end
  end

  it 'knows how many pages are in its result set' do
    solr = SolrSearch.new('test data')
    VCR.use_cassette('test-solr-pagination') do
      solr.total_pages.should eq(6)
    end
  end

  it 'can search in the title attributes' do
    solr = SolrSearch.new('title: test')
    VCR.use_cassette('test solr title searches') do
      solr.records.first['title'].downcase.should include 'test'
    end
  end

  it 'can search with a specific site' do
    solr = SolrSearch.new('test site: nope7beergoa64ih.onion')
    VCR.use_cassette('solr searches a single site') do
      solr.records.map{|r| r['host'] }.should == (['nope7beergoa64ih.onion'] * 10)
    end
  end


  it 'can remove a specific site' do
    solr = SolrSearch.new('title: test -site: jppcxclcwvkbh3xi.onion')
    VCR.use_cassette('solr searches a without single site') do
      solr.records.first['host'].should_not eq 'jppcxclcwvkbh3xi.onion'
    end
  end

  it 'gracefully handles Solr being offline' do
    solr = SolrSearch.new('offline')
    stub_request(:get, solr.send(:solr_url)).to_raise(Errno::ECONNREFUSED)
    solr.records.should be_empty
    solr.errors.should == ["Search offline"]
  end

  it 'highlights matches' do
    solr = SolrSearch.new('test data')
    VCR.use_cassette('test-solr-totals') do
      url = solr.records.first['id']
      solr.highlights[url]['title'].first.should eq "About the BlackMarket <span class=\"highlight\">Data</span> Board"
    end
  end

  it 'responds to search or records' do
    solr = SolrSearch.new('test data')
    VCR.use_cassette('test-solr-totals') do
      solr.records.should eq solr.search
    end
  end

end
