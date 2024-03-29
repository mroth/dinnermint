#!/usr/bin/env ruby
require 'choice'

$LOAD_PATH << '.'
require 'flickrauth'
require 'dmphoto'
require 'foursquare'
require 'status'
include Status 

Choice.options do
  option :dryrun do
    long '--dryrun'
    desc 'Do not actually make changes, just show what would we done'
  end
  option :max do
    short '-n'
    long '--num=NUM'
    desc 'Maximum amount of photos to parse'
    default 20
  end
  option :all do
    short '-a'
    long '--all'
    desc "Process all photos, not just previously unprocessed ones."
    default false
  end
end

def process
  FlickrAuth.auth_setup('write')
  FlickrAuth.do_login()
  list = DMPhoto.find(:all => Choice[:all], :max => Choice[:max])
  fs = FoursquareHelper.new
  
  peopletags_added = 0
  photosets_added = 0
  placetags_added = 0
  
  list.each do |photo|
    ohai("\nFound image #{photo.title} (#{photo.short_url})")
    
    if not item_status( photo.has_ptags?, "people tagged" )
      didit "add person tag 97506353@N00"
      if not Choice[:dryrun]
        photo.add_ptags!
      end
      peopletags_added += 1
    end
    
    if not item_status( photo.in_set?, "in the dinnerwithyou photoset")
      didit "add to photoset 72157624485313757"
      if not Choice[:dryrun]
        photo.add_set!
        izdun
      end
      photosets_added += 1
    end

    match = fs.historyMatch( Time.parse(photo.date_taken) )
    matched = (match.distance.abs < 3600) #within the hour
    
    if not item_status( photo.has_placetag?, "place tagged with a foursquare id")
      #match = fs.historyMatch( Time.parse(photo.date_taken) )
      canduz "closest match: #{match.distance} seconds difference at \"#{match.checkin.venue.name.bold}\""
      if !matched 
        canduz "iz match close enuf? [#{'NOWAI'.red}]"
      else
        canduz "iz match close enuf? [#{'YEP'.green}]"
        didit "add machinetag foursquare:venue=#{match.checkin.venue.id}"
        if not Choice[:dryrun]
          photo.add_placetag(match.checkin.venue.id)
          izdun
        end
        placetags_added += 1
      end
    end
    
    if not item_status(  !photo.has_generic_title?, "in possession of a non-generic title" )
      if matched
        didit "set title to \"#{match.checkin.venue.name}\"" #match isnt instantiated if there is arelady a 4s id..
        if not Choice[:dryrun]
          photo.set_title(match.checkin.venue.name)
          izdun
        end
      else
        canduz "can't do shit about that"
      end
    end
    
    if not item_status( photo.is_processed?, "marked processed by dinnermint" )
      didit "marking processed"
      if not Choice[:dryrun]
        photo.mark_processed!
        izdun
      end
    end
  end
  
  puts "\n\n*********** STATS FEST '99 ***********".white.bold
  puts "People tags added: #{peopletags_added}".white.bold
  puts "Photo sets  added: #{photosets_added}".white.bold
  puts "Foursquare placetags added: #{placetags_added}".white.bold
end

process()
