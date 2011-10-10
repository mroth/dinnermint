require 'flickraw'
# require './auth.rb'
require './dinnermint'
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
  list = dm.get_all()
  list.each do |photo|
    ohai("Found image #{photo.title} (#{photo.short_url})")
    
    if not item_status( photo.has_ptags?, "people tagged" )
      #puts "doing something"
    end
    
    item_status( photo.in_set?, "in the dinnerwithyou photoset")
    item_status( photo.has_placetag?, "place tagged with a foursquare id")
  end
end
