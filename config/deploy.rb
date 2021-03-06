# encoding: utf-8
# rubocop:disable LineLength, RescueModifier, ColonMethodCall
# Capistrano configuration. Now with TRUE zero-downtime unless DB migration.
#
# require 'new_relic/recipes'         - Newrelic notification about deployment
# require 'capistrano/ext/multistage' - We use 2 deployment environment: staging and production.
# set :deploy_via, :remote_cache      - fetch only latest changes during deployment
# set :normalize_asset_timestamps     - no need to touch (date modification) every assets
# 'deploy:web:disable'                - traditional maintenance page (during DB migrations deployment)
# task :restart                       - Unicorn with preload_app should be reloaded by USR2+QUIT signals, not HUP
#
# http://unicorn.bogomips.org/SIGNALS.html
# 'If 'preload_app' is true, then application code changes will have no effect;
# USR2 + QUIT (see below) must be used to load newer code in this case'
#
# config/deploy.rb

require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'new_relic/recipes'
require 'dotenv/capistrano'

set :stages,                     %w(staging production)
set :default_stage,              'production'

set :scm,                        :git
set :repository,                 'git@bitbucket.org:TorSearch/torsearch.git'
set :deploy_via,                 :remote_cache
set :keep_releases, 3

# For running things with `sudo`
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :application,                'torsearch'
set :use_sudo,                   true
set :user,                       'app'
set :normalize_asset_timestamps, false

before 'deploy',                 'deploy:delayed_job:stop'
before 'deploy:migrations',      'deploy:web:disable'

after  'deploy:update_code',     'deploy:symlink_shared'

after 'deploy:create_symlink',   'deploy:chmod_dj'# , 'deploy:chmod_unicorn'
after  'deploy',                 'newrelic:notice_deployment', 'deploy:cleanup', 'deploy:delayed_job:restart'
after  'deploy:migrations',      'deploy:web:enable', 'newrelic:notice_deployment', 'deploy:cleanup', 'deploy:delayed_job:restart'# , 'deploy:solr_restart'# ,

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: { no_release: true } do
      run "sudo god #{command} tor_search"
    end
  end
  desc 'make unicorn executable'
  task :chmod_unicorn, roles: :app, except: { no_release: true } do
    run "chmod +x #{current_path}/config/server/unicorn_init.sh"
  end

  desc 'make dj executable'
  task :chmod_dj do
    run "cd #{current_path}; chmod +x script/delayed_job"
  end

  desc 'Link in the production database.yml and assets'
  task :symlink_shared do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/shared/config/solr.yml #{release_path}/config/solr.yml"
    run "ln -nfs #{deploy_to}/shared/config/redis.yml #{release_path}/config/redis.yml"
  end

  namespace :delayed_job do
    desc 'Restart the delayed_job process'
    task :restart, roles: :app, except: { no_release: true } do
      run "cd #{current_path}; sudo RAILS_ENV=#{rails_env} bundle exec script/delayed_job restart" rescue nil
    end
    desc 'Stop the delayed_job process'
    task :stop, roles: :app, except: { no_release: true } do
      run "cd #{current_path}; sudo RAILS_ENV=#{rails_env} bundle exec script/delayed_job stop" rescue nil
    end
  end

  namespace :db do
    desc 'backup of database before migrations are invoked'
    task :backup, roles: :db, only: { primary: true } do
      filename = "#{deploy_to}/shared/db_backup/#{stage}_db.#{Time.now.utc.strftime('%Y-%m-%d_%I:%M')}_before_deploy.gz"
      text = capture "cat #{deploy_to}/current/config/database.yml"
      yaml = YAML::load(text)["#{stage}"]

      on_rollback { run "rm #{filename}" }
      run "mysqldump --single-transaction --quick -u#{yaml['username']} -h#{yaml['host']} -p#{yaml['password']} #{yaml['database']} | gzip -c > #{filename}"
    end
  end

  namespace :web do
    desc 'Maintenance start'
    task :disable, roles: :web do
      #on_rollback { run "rm #{shared_path}/system/maintenance.html" }
      #page = File.read('public/503.html')
      #put page, "#{shared_path}/system/maintenance.html", mode: 0644
    end

    desc 'Maintenance stop'
    task :enable, roles: :web do
      #run "rm #{shared_path}/system/maintenance.html"
    end
  end

end

namespace :logs do
  desc "tail rails logs"
  task :tail_rails, :roles => :app do
    trap("INT") { puts 'Interupted'; exit 0; }
    run "sudo tail -f /var/log/syslog" do |channel, stream, data|
      puts "#{data}"
      break if stream == :err
    end
  end
end
# rubocop:enable LineLength,RescueModifier, ColonMethodCall

require './config/boot'
require 'airbrake/capistrano'
