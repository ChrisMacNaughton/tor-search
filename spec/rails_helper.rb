ENV["RAILS_ENV"] ||= 'test'
require 'bundler'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.include Rails.application.routes.url_helpers, type: :request
  #config.global_fixtures = :all
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock # or :fakeweb
  #c.ignore_request { |request| URI(request.uri).host =~ /127\.0\.0\.1/ }
end
