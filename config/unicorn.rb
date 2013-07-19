# config/unicorn.rb
if ENV["RAILS_ENV"] == "development"
  worker_processes 2
else
  worker_processes 6
end
preload_app true
# What to do before we fork a worker

# This is where we specify the socket.
# We will point the upstream Nginx module to this socket later on
listen "/var/rails/tor_search/current/tmp/sockets/unicorn.sock", :backlog => 64

pid "/var/rails/tor_search/current/tmp/pids/unicorn.pid"

working_directory "/var/rails/tor_search/current"

before_fork do |server, worker|
    defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!

  old_pid = %x(ps -ef | grep 'unicorn master (old)' | grep -v grep | awk '{print $2}').strip

  # zero downtime deploy magic:
  # if unicorn is already running, ask it to start a new process and quit.
  if old_pid != '' && server.pid != old_pid
    begin
      Process.kill("QUIT", old_pid.to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

end

# What to do after we fork a worker
after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end

timeout 30