require 'flickraw'
# require './auth.rb'
require './dinnermint'
require './foursquare'
require 'colored'

dm = DinnerMint.new()

def ohai(msg)
  puts msg.white
end
def opoo(msg)
  puts msg.red
end
def oyay(msg)
  puts msg.green
end
def canduz(msg)
  puts "\t--- #{msg}"
end
def didit(msg)
  puts "\t*** #{msg}".yellow
end

desc "clear the list of which files have been processed"
task :clear_processed do
  list=flickr.photos.search(:user_id => 'me', :tags => 'dinnerwithyou', :per_page => '500', :extras => 'machine_tags')
end

desc "show which files matching the tag have been processed and which have not"
task :show_processed do
  list=flickr.photos.search(:user_id => 'me', :tags => 'dinnerwithyou', :per_page => '500', :extras => 'machine_tags')
  list.each do |photo|
    photo
  end
end

def item_status( test_function, desc )
  if test_function
    oyay("...is #{desc}.")
  else
    opoo("...is not #{desc}.")
  end
  return test_function
end

task :process do
  fs = FoursquareHelper.new
  list = DMPhoto.find(:all)
  
  peopletags_added = 0
  photosets_added = 0
  placetags_added = 0
  
  list.each do |photo|
    ohai("\nFound image #{photo.title} (#{photo.short_url})")
    
    if not item_status( photo.has_ptags?, "people tagged" )
      didit "add person tag 97506353@N00"
      peopletags_added += 1
    end
    
    if not item_status( photo.in_set?, "in the dinnerwithyou photoset")
      didit "add to photoset 72157624485313757"
      photosets_added += 1
    end
    
    # item_status( photo.has_placetag?, "place tagged with a foursquare id")
    if not item_status( photo.has_placetag?, "place tagged with a foursquare id")
      match = fs.historyMatch( Time.parse(photo.date_taken) )
      canduz "closest match: #{match.distance} seconds difference at \"#{match.checkin.venue.name.bold}\""
      if (match.distance.abs > 3600) #within the hour
        canduz "iz match close enuf? [#{'NOWAI'.red}]"
      else
        canduz "iz match close enuf? [#{'YEP'.green}]"
        didit "add machinetag foursquare:venue=#{match.checkin.venue.id}"
        placetags_added += 1
      end
    end
  end
  
  puts "\n\n*********** STATS FEST '99 ***********".white.bold
  puts "People tags added: #{peopletags_added}".white.bold
  puts "Photo sets  added: #{photosets_added}".white.bold
  puts "Foursquare placetags added: #{placetags_added}".white.bold
end
