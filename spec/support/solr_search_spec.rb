describe SolrSearch do

  it 'can get the number of indexed docs' do
    VCR.use_cassette('get_solr_index_size') do
      search = SolrSearch.new

      search.indexed.should == 134509
    end
  end

  it "doesn't return banned domains in the search" do
    VCR.use_cassette('get_fresh_solr_search') do
      search = SolrSearch.new('test')
      host = search.records.first['host']
      #debugger
      BannedDomain.create!(hostname: host, reason: "Testing!!!")
    end

    VCR.use_cassette('get_rejected_solr_search') do
      host2 = SolrSearch.new('test').records.first['host']
      host1 = BannedDomain.first.hostname
      host2.should_not == host1
    end
  end

  it "can have its query set after initialization"

  it "can have its page set after initialization"

  it "knows how many results it returned"

  it "knows how many oages are in its result set"

  it "highlights matches in the results"

  it "gracefully handles Solr being offline"

  it "shows 0 indexed when Solr is offline"

  it "can search in the title attributes"

  it "can search with a specific site"

  it "can remove a specific site"

  it "resets the arguments when an argument changes"
end