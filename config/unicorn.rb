# encoding: utf-8

# Unicorn configuration file to be running by
# unicorn_init.sh with capistrano task
# read an example configuration before:
#   http://unicorn.bogomips.org/examples/unicorn.conf.rb

app_path          = '/var/rails/tor_search/current'

working_directory app_path
pid               "#{app_path}/tmp/pids/unicorn.pid"
stderr_path       "#{app_path}/log/unicorn.log"
stdout_path       "#{app_path}/log/unicorn.log"

listen            '/tmp/unicorn.production.sock'
worker_processes  2
timeout           30
preload_app       true

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{app_path}/Gemfile"
  # rubocop:disable all
  ENV['SECRET_TOKEN'] = 'fd52e049ef76b6e1a50cbe33d8967b32f0e9741e17ccb3d49e254426790318597107b4a6df160b7d5fd4ccfea8513b3f55e640e3c1be1de0a673d4e2514c4c96'
  # rubocop:enable all
end

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  old_pid = "#{app_path}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    Process.kill('TTOU', File.read(server.pid).to_i)
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH # rubocop:disable HandleExceptions
      # someone else did our job for us
    end
    Process.kill('TTIN', File.read(server.pid).to_i)
  end
  sleep 1
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
