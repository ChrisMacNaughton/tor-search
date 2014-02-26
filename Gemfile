source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '3.2.17'

# Use sqlite3 as the database for Active Record
gem 'pg'
gem 'syslogger'
# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'gruff'

gem 'rsolr'

gem 'will_paginate'

gem 'devise'

gem 'haml'
gem 'haml-rails'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

gem 'active_model_serializers'

gem 'angularjs-rails-resource'
gem "daemons"
gem 'delayed_job_active_record'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'mixpanel-ruby'
#gem 'delayed_job_active_record'
#gem 'daemons'

# allows parallel web requests from the application
gem 'typhoeus'

gem 'rails_admin'

# be able to get addresses and such!
gem 'coinbase'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 1.2'

gem 'paranoia'

group :development do
  gem 'meta_request'
  gem 'better_errors'
  gem 'foreman'
end
group :test do
  #gem 'capybara', require: false
  gem 'rspec-rails', require: false
  gem 'webmock'
  gem 'vcr'
  gem 'simplecov', require: false
end

gem 'pry', group: [:development, :test]
# Use unicorn as the app server
gem 'unicorn'
gem 'newrelic_rpm'
gem 'dotenv-rails' # Used to install environment variables
gem 'airbrake'

gem "acts_as_textcaptcha", "~> 3.0.10"
# Use Capistrano for deployment
gem 'capistrano', '~> 2.15.5', group: :development

group :production do
  gem "redis-rails", "~> 3.2.3"
end
