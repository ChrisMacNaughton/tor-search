# Unicorn configuration file to be running by unicorn_init.sh with capistrano task
# read an example configuration before: http://unicorn.bogomips.org/examples/unicorn.conf.rb
#
# working_directory, pid, paths - internal Unicorn variables must to setup
# worker_process 4              - is good enough for serve small production application
# timeout 30                    - time limit when unresponded workers to restart
# preload_app true              - the most interesting option that confuse a lot of us,
#                                 just setup is as true always, it means extra work on
#                                 deployment scripts to make it correctly
# BUNDLE_GEMFILE                - make Gemfile accessible with new master
# before_fork, after_fork       - reconnect to all dependent services: DB, Redis, Sphinx etc.
#                                 deal with old_pid only if CPU or RAM are limited enough
#
# config/server/production/unicorn.rb


app_path          = "/var/rails/tor_search/current"

working_directory "#{app_path}"
pid               "#{app_path}/tmp/pids/unicorn.pid"
stderr_path       "#{app_path}/log/unicorn.log"
stdout_path       "#{app_path}/log/unicorn.log"

listen            "/tmp/unicorn.production.sock"
worker_processes  2
timeout           30
preload_app       true


before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{app_path}/Gemfile"
end


before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  if defined?(Resque)
    Resque.redis.quit
  end
  old_pid = "#{app_path}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    Process.kill("TTOU", File.read(server.pid).to_i)
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
    Process.kill("TTIN", File.read(server.pid).to_i)
  end
  sleep 1
end


after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  if defined?(Resque)
    Resque.redis           = 'localhost:6379'
  end
end