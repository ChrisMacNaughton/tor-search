require 'net/http'
require 'json'
namespace :domains do

  desc 'Grab new domains from tor2web.fi'
  task :fetch_requested_domains => :environment do
    uri = URI 'https://tor2web.fi/antanistaticmap/stats/yesterday'
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    res = Net::HTTP.get uri
    json = JSON.parse(res)
    json['hidden_services'].map do |host|
      Domain.add_later("#{host['id']}.onion")
    end
  end
end