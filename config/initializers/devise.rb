# encoding: utf-8
# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|

  config.mailer_sender = 'chris.torsearch@gmail.com'
  require 'devise/orm/active_record'
  config.authentication_keys = [:username]
  config.case_insensitive_keys = [:email, :username]
  config.strip_whitespace_keys = [:email, :username]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  # rubocop:disable all
  config.pepper = '7008474229656912c4e10e2a5c0b93d2c81baebd0a665a870f53fc9072373e01a1df4bde8524b3d67aff64a27fd7eb28e477175c43dede29650a3f848b13817a'
  # rubocop:enable all
  config.reconfirmable = true
  config.password_length = 8..512
  config.reset_password_within = 6.hours
  config.scoped_views = true
  config.sign_out_via = :get

end
