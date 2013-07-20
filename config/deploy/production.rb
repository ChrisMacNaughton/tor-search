# capistrano production config
#
# config/deploy/production.rb


server "ec2-54-224-36-225.compute-1.amazonaws.com",                :app, :web, :db, :primary => true
set :branch,                     "production"
set :deploy_to,                  "/var/rails/tor_search"
set :rails_env,                  "production"