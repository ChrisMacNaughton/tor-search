require 'net/http'
require 'json'
namespace :domains do

  desc 'Grab new domains from tor2web.fi'
  task :fetch_requested_domains => :environment do
    begin
      Rails.logger.info "Fetching domains from tor2web.fi"
      uri = URI 'https://tor2web.fi/antanistaticmap/stats/yesterday'
      OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
      res = Net::HTTP.get uri
      json = JSON.parse(res)
      json['hidden_services'].map do |host|
        Domain.add_later("#{host['id']}.onion")
      end
    rescue
      nil
    end

    begin
      Rails.logger.info "Fetching domains from onion.to"
      uri = URI 'https://onion.to/antanistaticmap/stats/yesterday'
      OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
      res = Net::HTTP.get uri
      json = JSON.parse(res)
      json['hidden_services'].map do |host|
        Domain.add_later("#{host['id']}.onion")
      end
    rescue
      nil
    end
  end
end