#!/usr/bin/env ruby

#
# Convenience file to handle reading/writing Flickr Auth vars from a config.yml
#
require 'flickraw'
require 'yaml'
require 'launchy'

module FlickrAuth

  #initialize helper libraries
  ROOT = File.dirname(__FILE__) unless defined?(ROOT)
  CONFIG = YAML.load_file("#{ROOT}/config.yml") unless defined? CONFIG

  def self.read_config
    FlickRaw.api_key=CONFIG['flickr_api_key']
    FlickRaw.shared_secret=CONFIG['flickr_shared_secret']
    flickr.access_token = CONFIG['flickr_access_token']
    flickr.access_secret = CONFIG['flickr_access_secret']
  end

  def self.auth_setup(perms='read')
    read_config()
    if not (has_api_keys? && valid_api_keys?)
      abort "You need to put a real and valid API key and secret in the config.yml file!\n---\nflickr_api_key: foo\nflickr_shared_secret: bar"
    end
    if not has_user_tokens?
      get_user_tokens(perms)
    end
  end

  def self.has_user_tokens? 
    !CONFIG['flickr_access_token'].nil? && !CONFIG['flickr_access_secret'].nil?
  end

  def self.has_api_keys?
    !CONFIG['flickr_api_key'].nil? && !CONFIG['flickr_shared_secret'].nil?
  end

  def self.valid_api_keys?
    return true #TODO: actually test this! for now we just throw an error
  end

  def self.get_user_tokens(perms='read')
    token = flickr.get_request_token
    auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => perms)
  
    puts "Opening web browser to do Flickr auth process"
    Launchy.open(auth_url)
    print "Copy here the number given when you complete the process: "
    verify = gets.strip
  
    begin
      flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
      login = flickr.test.login
      puts "You are now authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
      CONFIG['flickr_access_token'] = flickr.access_token
      CONFIG['flickr_access_secret'] = flickr.access_secret
      File.open('config.yml', 'w') do |out|
        out.write(CONFIG.to_yaml)
      end
    rescue FlickRaw::FailedResponse => e
      puts "Authentication failed : #{e.msg}"
    end
  end

  def self.do_login
    begin
      login = flickr.test.login
      puts "You are now authenticated as #{login.username}"
    rescue FlickRaw::FailedResponse => e
      puts "Authentication failed : #{e.msg}"
    end
  end

end

