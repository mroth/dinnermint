require 'foursquare2'
require 'oauth2'
require 'launchy'
require 'colored'
require 'time'

class FoursquareHelper
  attr_accessor :client, :history
  
  def initialize
    read_config
    while (@user_token.nil? || @user_token == '')
      get_token
      read_config
    end
    @client = Foursquare2::Client.new(:oauth_token => @user_token)
    init_history
  end
  
  def read_config
    @config = YAML.load_file("config.yml")
    @client_id=@config['foursquare_client_id']
    @client_secret=@config['foursquare_client_secret']
    @user_token=@config['foursquare_user_token']
  end
 
  def get_token
    puts "No foursquare user token, go auth us and get one, sucker!".red
    
    o_client = OAuth2::Client.new(@client_id, @client_secret, {:site => 'https://foursquare.com/', :authorize_url => 'oauth2/authenticate'})
    auth_url = o_client.auth_code.authorize_url(
      :redirect_uri => 'http://mroth.github.com/foursquare-token-echo/', 
      :response_type => 'token'
    )
    Launchy.open(auth_url)
    
    print 'Okay, now gimmee ur token: '.bold
    token = gets.chomp
    puts "Writing token #{token} to config.yml...".green
    
    @config['foursquare_user_token'] = token
    File.open('config.yml', 'w') do |out|
      out.write(@config.to_yaml)
    end
  end
  
  def init_history
    @history = @client.user_checkins(:limit => '250')
  end
  
  def test
    checkin = @history.items[0]
    id = checkin.venue.id
    name = checkin.venue.name
    lat = checkin.venue.location.lat
  end
  
  def historyMatch(ts) #assume a Time object
    mrc = Time.at( @history.items[0].createdAt )
    mrp = ts
    mrp_i = ts.to_i
    
    stamps=[]
    @history.items.each do |c|
      stamps << c.createdAt
    end
    
    distances=[]
    stamps.each do |s|
      distances << mrp_i - s
    end
    
    min_distance = distances.min_by {|x| x.abs} #distance from zero
    min_position = distances.find_index( min_distance )
    checkin = @history.items[ min_position ]
    closest = { :distance => min_distance, :position => min_position, :checkin => checkin }
  end

end