describe SolrSearch do
  it 'can get the number of indexed docs' do
    VCR.use_cassette('get_solr_index_size') do
      search = SolrSearch.new

      search.indexed.should == 134509
    end
  end
end