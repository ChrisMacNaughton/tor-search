current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "chrismacnaughton"
client_key               "~/.chef/chrismacnaughton.pem"
validation_client_name   "torsearch-validator"
validation_key           "#{current_dir}/torsearch-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/torsearch"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
