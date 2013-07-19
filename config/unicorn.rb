# What to do right before exec()-ing the new unicorn binary
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = '/var/rails/tor_search/current/Gemfile'
end


# What to do before we fork a worker
before_fork do |server, worker|
    defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!

  old_pid = "/var/rails/tor_search/shared/pids/tor_search.pid.oldbin"

  # zero downtime deploy magic:
  # if unicorn is already running, ask it to start a new process and quit.
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

end

# What to do after we fork a worker
after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end

# Where to drop a pidfile
pid '/var/rails/tor_search/shared/pids/tor_search.pid'

# Where stderr gets logged
stderr_path '/var/rails/tor_search/shared/log/tor_search.stderr.log'

# Where stdout gets logged
stdout_path '/var/rails/tor_search/shared/log/tor_search.stdout.log'

# https://newrelic.com/docs/ruby/ruby-gc-instrumentation
if GC.respond_to?(:enable_stats)
  GC.enable_stats
end
if defined?(GC::Profiler) and GC::Profiler.respond_to?(:enable)
  GC::Profiler.enable
end