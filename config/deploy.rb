require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'new_relic/recipes'

set :stages,                     %w(staging production)
set :default_stage,              "production"

set :scm,                        :git
set :repository,                 "..."
set :deploy_via,                 :remote_cache
default_run_options[:pty]        = true

set :application,                "tor_search"
set :use_sudo,                   false
set :user,                       "app"
set :normalize_asset_timestamps, false

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "ec2-54-224-36-225.compute-1.amazonaws.com"                          # Your HTTP server, Apache/etc
role :app, "ec2-54-224-36-225.compute-1.amazonaws.com"                          # This may be the same as your `Web` server
role :db,  "ec2-54-224-36-225.compute-1.amazonaws.com", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

before "deploy",                 "deploy:delayed_job:stop"
before "deploy:migrations",      "deploy:delayed_job:stop"

after  "deploy:update_code",     "deploy:symlink_shared"
before "deploy:migrate",         "deploy:web:disable", "deploy:db:backup"

after  "deploy",                                      "newrelic:notice_deployment", "deploy:cleanup", "deploy:delayed_job:restart"
after  "deploy:migrations",      "deploy:web:enable", "newrelic:notice_deployment", "deploy:cleanup", "deploy:delayed_job:restart"

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:update_code", "deploy:migrate"
after "deploy:restart", "deploy:cleanup"
after "deploy:restart", "deploy:restart_solr"
set :rails_env, :production

set :deploy_to, "/var/rails/#{application}"

set :scm, :git
# Instead of doing a full clone, get only changes
set :deploy_via, :remote_cache
set :keep_releases, 3

# user on the server
set :user, "ubuntu"
set :use_sudo, true

namespace :deploy do
  task :solr_restart, roles: :app, except: {no_release: true} do
    run "curl http://localhost:8983/solr/admin/cores?wt=json&action=RELOAD&core=collection1"
  end
  %w[start stop].each do |command|
    desc "#{command} unicorn server"
    task command, :roles => :app, :except => { :no_release => true } do
      run "#{current_path}/config/server/#{rails_env}/unicorn_init.sh #{command}"
    end
  end

  desc "restart unicorn server"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{current_path}/config/server/#{rails_env}/unicorn_init.sh upgrade"
  end


  desc "Link in the production database.yml and assets"
  task :symlink_shared do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  namespace :delayed_job do
    desc "Restart the delayed_job process"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec script/delayed_job restart" rescue nil
    end
    desc "Stop the delayed_job process"
    task :stop, :roles => :app, :except => { :no_release => true } do
      run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec script/delayed_job stop" rescue nil
    end
  end


  namespace :db do
    desc "backup of database before migrations are invoked"
    task :backup, :roles => :db, :only => { :primary => true } do
      filename = "#{deploy_to}/shared/db_backup/#{stage}_db.#{Time.now.utc.strftime("%Y-%m-%d_%I:%M")}_before_deploy.gz"
      text = capture "cat #{deploy_to}/current/config/database.yml"
      yaml = YAML::load(text)["#{stage}"]

      on_rollback { run "rm #{filename}" }
      run "mysqldump --single-transaction --quick -u#{yaml['username']} -h#{yaml['host']} -p#{yaml['password']} #{yaml['database']} | gzip -c > #{filename}"
    end
  end


  namespace :web do
    desc "Maintenance start"
    task :disable, :roles => :web do
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }
      page = File.read("public/503.html")
      put page, "#{shared_path}/system/maintenance.html", :mode => 0644
    end

    desc "Maintenance stop"
    task :enable, :roles => :web do
      run "rm #{shared_path}/system/maintenance.html"
    end
  end

end


namespace :log do
  desc "A pinch of tail"
  task :tailf, :roles => :app do
    run "tail -n 10000 -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
      puts "#{data}"
      break if stream == :err
    end
  end
end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end