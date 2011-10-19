#!/usr/bin/env ruby
require 'flickrauth'
require 'base58'

class DMPhoto
  attr_accessor :id, :title, :tags, :machine_tags, :date_taken, :po
  @@dwy_photoset_array = nil
  
  PROCESSED_TAG = 'dinnermint:processed=true'
  DWY_TAG = 'dinnerwithyou'
  TARA_NSID = '97506353@N00'
  DWY_PHOTOSET_ID = '72157624485313757'
  
  def initialize(id,title,tags,machine_tags, date_taken)
    @id = id
    @title = title
    @tags = tags
    @machine_tags = machine_tags
    @date_taken = date_taken
    # @po = flickr.photos.getInfo(:photo_id => id) 
    @po = nil #a full photo object for parsing convenience
    init_dwy_photoset_array()
  end
  
  def init_po
    #initalizing the photo object requires a new API call that can take a while, so we only want to do it when needed
    @po = flickr.photos.getInfo(:photo_id => id) 
  end
  
  # return existing array if already init'd, otherwise generate
  def init_dwy_photoset_array
    if @@dwy_photoset_array.nil?
      resp=flickr.photosets.getPhotos(:photoset_id => DWY_PHOTOSET_ID)
      dwy=[]
      resp.photo.each do |p|
        dwy << p.id
      end
      @@dwy_photoset_array = dwy
    else
    end
  end
  
  #get all unprocessed dinnerwithyou photos (pass :all to get 'em ALL!)
  def self.find(opts={})
    list = flickr.photos.search(:user_id => 'me', :tags => DWY_TAG, :per_page => opts[:max] || 500, :extras => 'date_taken,geo,tags,machine_tags')
    results = []
    list.each do |p|
      # binding.pry
      print '.'
      if ((not p.machine_tags =~ /#{PROCESSED_TAG}/) || opts[:all]) #true if 
        results << DMPhoto.new(p.id, p.title, p.tags, p.machine_tags, p.datetaken )
      end
    end
    return results
  end
  
  def mark_processed
    flickr.photos.addTags(:photo_id => photo.id, :tags => PROCESSED_TAG)
  end
  
  def has_ptags?
    if @po.nil? then init_po end
    @po.people.haspeople != 0 #for now assume if it has a person in it, its the correct one
  end
  
  def add_ptags!
    flickr.photos.people.add(:photo_id => @id, :user_id => TARA_NSID)
  end

  def in_set?
    @@dwy_photoset_array.include?(@id)
  end
  
  def add_set!
    flickr.photosets.addPhoto(:photo_id => @id, :photoset_id => DWY_PHOTOSET_ID)
  end
  
  def has_placetag?
    @machine_tags =~ /foursquare:venue=/
  end
  
  def add_placetag(pid)
    flickr.photos.addTags(:photo_id => @id, :tags => "foursquare:venue=#{pid}")
  end
  
  def has_generic_title?
    @title =~ /photo.JPG/
  end
  
  def set_title(title)
    flickr.photos.setMeta( :photo_id => @id, :title => title)
  end
  
  def is_processed?
    @machine_tags =~ /#{PROCESSED_TAG}/
  end
  
  def mark_processed!
    flickr.photos.addTags(:photo_id => @id, :tags => "#{PROCESSED_TAG}")
  end
  
  def short_url
    "http://flic.kr/p/#{Base58.encode(@id.to_i)}"
  end
  
end