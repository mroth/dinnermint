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
    list = flickr.photos.search(:user_id => 'me', :tags => 'dinnerwithyou', :per_page => '500', :extras => 'geo,tags,machine_tags')
    results = []
    list.each do |p|
      results << DMPhoto.new(p.id, p.title, p.tags, p.machine_tags )
    end
    return results
  end
    
  #get full photo object
  def get_photo_obj(photo)
    flickr.photos.getInfo(:photo_id => photo.id)
  end
  
end

class DMPhoto
  attr_accessor :id, :title, :tags, :machine_tags, :po
  
  def initialize(id,title,tags,machine_tags)
    @id = id
    @title = title
    @tags = tags
    @machine_tags = machine_tags
    # @po = flickr.photos.getInfo(:photo_id => id) 
    @po = nil #a full photo object for parsing convenience
  end
  
  def init_po
    #initalizing the photo object requires a new API call that can take a while, so we only want to do it when needed
    @po = flickr.photos.getInfo(:photo_id => id) 
  end
  
  def mark_processed
    flickr.photos.addTags(:photo_id => photo.id, :tags => $processed_tag)
  end
  
  def has_ptags?
    if @po.nil? then init_po end
    @po.people.haspeople != 0 #for now assume if it has a person in it, its the correct one
  end
  
  def add_ptags
    flickr.photos.people.add(:photo_id => @id, :user_id => $tara_nsid)
  end

  def in_set?
    $dwy_photoset_array.include?(@id)
  end
  
  def has_placetag?
    @machine_tags =~ /foursquare:venue=/
  end
  
  def short_url
    "http://flic.kr/p/#{Base58.encode(@id.to_i)}"
  end
  
end

# dm=DinnerMint.new
# binding.pry