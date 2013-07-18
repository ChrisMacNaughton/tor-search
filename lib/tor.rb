#!/usr/bin/env ruby
require 'socksify'
require 'mechanize'
require 'net/telnet'

class Tor
  #debug
  #Socksify::debug = true

  def initialize(control_port='9151',socks_port='9150')
    @tor_control_port = control_port
    @tor_socks_port   = socks_port
    TCPSocket::socks_server = "127.0.0.1"
    TCPSocket::socks_port = @tor_socks_port
  end

  def get_current_ip_address
    # rubyforge_www = TCPSocket.new("rubyforge.org", 80)
    a = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac FireFox'
    end
    a.get('http://ifconfig.me/ip').body.chomp
  rescue Exception => ex
    puts "error getting ip: #{ex.to_s}"
    return ""
  end

  def get_new_ip
    puts "get new ip address"
    old_ip_address = get_current_ip_address
    tor_switch_endpoint
    sleep 10 # wait for connection
    new_ip_address = get_current_ip_address
    if (old_ip_address != new_ip_address) # Compare your old ip with your current one
      puts "ip changed from  #{old_ip_address} to #{new_ip_address}"
      return true
    else
      puts "ip same #{old_ip_address}"
      return false
    end
  end

  def tor_switch_endpoint
    puts "tor_switch_endpoint.."
    localhost = Net::Telnet::new("Host" => "localhost", "Port" => "#{@tor_control_port}", "Timeout" => 10, "Prompt" => /250 OK\n/)
    localhost.cmd('AUTHENTICATE "Emperor penguins are cool!"') { |c| print c; throw "Cannot authenticate to Tor" if c != "250 OK\n" }
    localhost.cmd('signal NEWNYM') { |c| print c; throw "Cannot switch Tor to new route" if c != "250 OK\n" }
    localhost.close
  end

  #block to be executed though the proxy
  def proxy_mechanize
    yield
  end

  def get(address)
    unless address =~ /https?:\/\//
      address = "http://#{address}"
    end
    proxy_mechanize do
      agent = Mechanize.new
      agent.user_agent = TorSearch::Application.config.user_agent
      begin
        agent.get(address)
      rescue Mechanize::ResponseCodeError
      end
    end
  end
  def get_image(address)
    proxy_mechanize do
      agent = Mechanize.new
      agent.user_agent = TorSearch::Application.config.user_agent
      begin
        r = agent.get(address)
        #puts "Got #{address}!"
        if r.is_a? Mechanize::Image
          #puts "It's an image!"
          return make_clean_file(r)
        elsif r.is_a? Mechanize::Page
          #puts "It's a page, trying some more!"
          r.links.each do |l|
            #puts "Getting #{address}!"
            t = l.click
            if t.is_a? Mechanize::Image
              return make_clean_file(t)
            else
              next
            end
          end
        else
          return nil
        end
      rescue Mechanize::ResponseCodeError
      end
    end
  end
  def make_clean_file(f)
    filename = f.filename
    name_parts = filename.split('.')
    name_parts.pop if name_parts.length > 1
    extension = f.response['content-type'].split("/")[-1]
    filename = "tmp/images/#{ name_parts.join('.')}.#{extension}"
    f.save_as("#{filename}")
    return filename
  end
end
