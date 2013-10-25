# encoding: utf-8

require 'simplecov'
SimpleCov.start 'rails'

require 'bundler'
require 'bundler/setup'
Bundler.require :test

RSpec.configure do |config|
  config.mock_framework = :rspec
end

require 'rails_helper'
