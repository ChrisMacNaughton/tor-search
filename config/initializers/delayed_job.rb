require "#{Rails.root}/lib/crawler/crawler"

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.hours
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.logger = Rails.logger
Delayed::Worker.default_priority = 5
Delayed::Worker.read_ahead = 1

Delayed::Worker.lifecycle.after :enqueue do |job|
  job.update_attribute :handler_hash, Digest::MD5.hexdigest(job.handler)
end
