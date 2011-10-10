require 'flickraw'
require './auth.rb'
# require 'colored'
# require 'choice'
require 'base58'
require 'pry'

class DinnerMint
  #some global vars
  $processed_tag = 'dinnermint:processed=true'
  $tag = 'dinnerwithyou'
  $tara_nsid = '97506353@N00'
  $dwy_photoset_id = '72157624485313757'
  $dwy_photoset_array = nil
  
  #
  # Get valid auth tokens
  #
  def initialize
    auth_setup('write')
    do_login()
    $dwy_photoset_array = get_dwy_photoset_array
  end

  def get_dwy_photoset_array
    resp=flickr.photosets.getPhotos(:photoset_id =>$dwy_photoset_id)
    dwy=[]
    resp.photo.each do |p|
      dwy << p.id
    end
    return dwy
  end
  

  # get all unprocessed dinnerwithyou photos
  def get_unprocessed
    unprocessed = []
    list = flickr.photos.search(:user_id => 'me', :tags => 'dinnerwithyou', :per_page => '500', :extras => 'geo,tags,machine_tags')
    list.each do |photo|
      if not photo.machine_tags =~ /$processed_tag/
        unprocessed << photo
      end
    end
    return unprocessed
  end
  
  #get all dinnerwithyou photos regardless of processed state
  def get_all
    flickr.photos.search(:user_id => 'me', :tags => 'dinnerwithyou', :per_page => '500', :extras => 'geo,tags,machine_tags')
  end
    
  #get full photo object
  def get_photo_obj(photo)
    flickr.photos.getInfo(:photo_id => photo.id)
  end
  
  def mark_processed(photo)
    flickr.photos.addTags(:photo_id => photo.id, :tags => $processed_tag)
  end
  
  def has_ptags?(po)
    po.people.haspeople != 0 #for now assume if it has a person in it, its the correct one
  end
  
  def add_ptags(photo)
    flickr.photos.people.add(:photo_id => photo.id, :user_id => $tara_nsid)
  end

  def in_set?(photo)
    $dwy_photoset_array.include?(photo.id)
  end
  
  def has_placetag?(photo)
    photo.machine_tags =~ /foursquare:venue=/
  end
  
  def short_url(photo)
    "http://flic.kr/p/#{Base58.encode(photo.id.to_i)}"
  end
  #if not tagged tara, add tag (?)
  #if not person tagged tara, add person tag
  #if not in proper set, add to set
  #check and set title based on foursquare match
  
end
