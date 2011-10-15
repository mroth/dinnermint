require 'foursquare2'
require 'oauth2'
require 'launchy'
require 'colored'

class FoursquareHistory
  attr_accessor :client, :user_token
  
  def initialize
    read_config
    if @user_token.nil?
      get_token
    end
  end
  
  def read_config
    config = YAML.load_file("config.yml")
    @client_id=config['foursquare_client_id']
    @client_secret=config['foursquare_client_secret']
    @user_token=config['foursquare_user_token']
  end
 
  def get_token
    @client = OAuth2::Client.new(@client_id, @client_secret, {:site => 'https://foursquare.com/', :authorize_url => 'oauth2/authenticate'})
    auth_url = @client.auth_code.authorize_url(
      :redirect_uri => 'http://mroth.github.com/foursquare-token-echo/', 
      :response_type => 'token'
    )
    
    puts "Nofoursquare user token, go auth us and get one, sucker.".red
    Launchy.open(auth_url)
    print 'Gimme ur token: '
    token = gets.chomp
    puts token
  end

end