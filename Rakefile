#!/usr/bin/env ruby

$LOAD_PATH << '.'
require 'dmphoto'
require 'foursquare'
require 'status'
include Status

task :auth do
  FlickrAuth.auth_setup('write')
  FlickrAuth.do_login()
end

desc "clear the list of which files have been processed"
task :clear_processed  => [:auth] do
  list = DMPhoto.find(:all)
  list.each do |photo|
    if photo.is_processed?
      canduz "marking photo #{photo.title} as unprocessed..."
    end
  end
end

# desc "show which files matching the tag have been processed and which have not"
# task :show_processed do
#   list=flickr.photos.search(:user_id => 'me', :tags => 'dinnerwithyou', :per_page => '500', :extras => 'machine_tags')
#   list.each do |photo|
#     photo
#   end
# end

