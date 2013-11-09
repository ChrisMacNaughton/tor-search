# encoding: utf-8
# rubocop:disable LineLength
require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module TorSearch
    # This is my app
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :en

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    config.generators do |g|
      g.template_engine :haml
      g.stylesheets :scss
      g.test_framework :rspec, fixtures: true
    end

    config.assets.initialize_on_precompile = false
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.serve_static_assets = true

    config.assets.precompile += %w(admin.js admin.css ads.css ads.js)
    config.assets.precompile += ['rails_admin/rails_admin.css', 'rails_admin/rails_admin.js']
    # Custom configuration defaults
    config.tor_search = ActiveSupport::OrderedOptions.new
    config.tor_search.coinbase_key = 'bfc79be3dc1282001d8fc17f8f664d41af4194449968ce47c0e24d8eba825b18'

    config.tor_search.tor_url = 'http://kbhpodhnfxl3clb4.onion'
    config.tor_search.bitcoin_address = '1PN1JwqftbqFWvpfoBCC2iJ4KBeY4xik6H'

    config.tor_search.pub_nub = ActiveSupport::OrderedOptions.new
    config.tor_search.pub_nub.publish_key = 'pub-c-64274781-1ba5-4e0e-92fa-dde91017cfb6'
    config.tor_search.pub_nub.subscribe_key = 'sub-c-5c3d413e-f314-11e2-8175-02ee2ddab7fe'
    config.tor_search.pub_nub.secret_key = 'sec-c-YTE0ZTU1MTEtMDVjZi00M2FmLWI1YTAtYTBmNjY4MDZjZDY5'
    config.tor_search.pub_nub.cipher_key = nil
    config.tor_search.pub_nub.ssl = nil

    config.tor_search.captcha_questions = [
        # Math questions
        { 'question' => 'two + 12', 'answers' => '14,fourteen' },
        { 'question' => '3 plus five', 'answers' => '8,eight' },
        { 'question' => 'twelve - 6', 'answers' => '6,six' },
        { 'question' => '2 times two', 'answers' => '4,four' },
        { 'question' => 'one times 11', 'answers' => '11,eleven' },
        { 'question' => '42 plus one', 'answers' => '43,forty-three,forty three' },
        { 'question' => '40 - ten', 'answers' => '30,thirty' },
        { 'question' => 'two plus five', 'answers' => '7,seven' },
        { 'question' => 'six times 2', 'answers' => '12,twelve' },
        { 'question' => 'one + one', 'answers' => 'two,2' },
        # Generic english questions
        { 'question' => 'Is a purple box green?', 'answers' => 'no' },
        { 'question' => 'If tomorrow is Saturday, what day is today?', 'answers' => 'friday,today' },
        { 'question' => 'If a duck is black, what kind of bird is it?', 'answers' => 'duck,a duck' },
        { 'question' => 'If a duck is black, what color is it?', 'answers' => 'black' },
        { 'question' => 'What color is the black house?', 'answers' => 'black' },
        { 'question' => 'What color is the red sky at sunset?', 'answers' => 'red' },
        { 'question' => 'What color is the white paper on the brown clipboard?', 'answers' => 'white' },
        { 'question' => 'Do cars need train tracks to drive?', 'answers' => 'no' },
        { 'question' => 'Is a square a rectangle?', 'answers' => 'yes' },
        { 'question' => 'Is a square a triangle?', 'answers' => 'no' }
    ]
  end
end
# rubocop:enable LineLength
