worker_processes 6

preload_app true
# What to do right before exec()-ing the new unicorn binary
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = 'Gemfile'
end

# What to do before we fork a worker
before_fork do |server, worker|
    defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!

end

# What to do after we fork a worker
after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end

# Where stderr gets logged
stderr_path 'log/tor_search.stderr.log'

# Where stdout gets logged
stdout_path 'log/tor_search.stdout.log'

timeout 30