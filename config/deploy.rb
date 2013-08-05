# Capistrano configuration. Now with TRUE zero-downtime unless DB migration.
#
# require 'new_relic/recipes'         - Newrelic notification about deployment
# require 'capistrano/ext/multistage' - We use 2 deployment environment: staging and production.
# set :deploy_via, :remote_cache      - fetch only latest changes during deployment
# set :normalize_asset_timestamps     - no need to touch (date modification) every assets
# "deploy:web:disable"                - traditional maintenance page (during DB migrations deployment)
# task :restart                       - Unicorn with preload_app should be reloaded by USR2+QUIT signals, not HUP
#
# http://unicorn.bogomips.org/SIGNALS.html
# "If “preload_app” is true, then application code changes will have no effect;
# USR2 + QUIT (see below) must be used to load newer code in this case"
#
# config/deploy.rb


require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'new_relic/recipes'

set :stages,                     %w(staging production)
set :default_stage,              "production"

set :scm,                        :git
set :repository,                 "git@bitbucket.org:IceyEC/torsearch.git"
set :deploy_via,                 :remote_cache
default_run_options[:pty]        = true

set :application,                "torsearch"
set :use_sudo,                   true
set :user,                       "ubuntu"
set :normalize_asset_timestamps, false


#before "deploy",                 "deploy:delayed_job:stop"
before "deploy:migrations",      "deploy:web:disable"

after  "deploy:update_code",     "deploy:symlink_shared"

after "deploy:create_symlink",   "deploy:chmod_unicorn", "deploy:chmod_dj", "deploy:chown_tor"
after  "deploy",                 "deploy:reload_monit", "newrelic:notice_deployment", "deploy:cleanup", "deploy:solr_restart"#, "deploy:delayed_job:restart"
after  "deploy:migrations",      "deploy:web:enable", "newrelic:notice_deployment", "deploy:cleanup"#, "deploy:delayed_job:restart"


namespace :deploy do
  task :solr_restart, roles: :app, except: {no_release: true} do
    run "curl http://localhost:8983/solr/admin/cores?wt=json&action=RELOAD&core=collection1"
  end
  desc "Restart the monit service."
  task :reload_monit, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} monit restart unicorn"
  end
  %w[start stop].each do |command|
    desc "#{command} unicorn server"
    task command, :roles => :app, :except => { :no_release => true } do
      run "#{current_path}/config/server/unicorn_init.sh #{command}"
    end
  end
  desc "make unicorn executable"
  task :chmod_unicorn, :roles => :app, :except => { :no_release => true } do
    run "chmod +x #{current_path}/config/server/unicorn_init.sh"
  end

  desc "make root own tor"
  task :chown_tor, :roles => :app, :except => { :no_release => true } do
    run "sudo chown -R root:root #{current_path}/config/tor"
  end

  desc "make dj executable"
  task :chmod_dj do
    run "cd #{current_path}; chmod +x script/delayed_job"
  end

  desc "restart unicorn server"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{current_path}/config/server/unicorn_init.sh reload"
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
  namespace :assets do
    task :precompile, :roles => :web do
      from = source.next_revision(current_revision) rescue nil
      if from.nil? || capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ lib/assets/ app/assets/ | wc -l").to_i > 0
        run_locally("rake assets:clean && rake assets:precompile")
        run_locally "cd public && tar -jcf assets.tar.bz2 assets"
        top.upload "public/assets.tar.bz2", "#{shared_path}", :via => :scp
        run "cd #{shared_path} && tar -jxf assets.tar.bz2 && rm assets.tar.bz2"
        run_locally "rm public/assets.tar.bz2"
        run_locally("rake assets:clean")
      else
        logger.info "Skipping asset precompilation because there were no asset changes"
      end
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