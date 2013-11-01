# encoding: utf-8
# capistrano production config
#
# config/deploy/production.rb

server 'dlweb02', \
      :app, :web, primary: true
#role :db, 'dlweb01'

set :gateway, 'cmacnaughton@sub.gesty.net:9022'
set :branch,                     'master'
set :deploy_to,                  '/var/rails/tor_search'
set :rails_env,                  'production'

