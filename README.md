I have a private set of photos on Flickr where I categories everywhere my girlfriend and I have dinner.  This script helps keep the metadata in order, so I can just email in a photo from my phone and the rest is taken care of for me automatically.  It's likely useless to anyone but me, but is here in case the code helps someone who wants to do something similar.

What the main script does:

 - pulls all my Flickr photos tagged 'dinnerwithyou'
 - checks to make sure they are in the correct set
 - checks to make sure they are properly people-tagged
 - does fuzzy matching with my foursquare checkins, and place-tag the photos based on those, as well as correct the title to the proper restaurant name
 - use a machinetag to keep track of which photos have already been processed


### Usage
```
Usage: dinnermint.rb [-na]
        --dryrun                     Do not actually make changes, just show what would we done
    -n, --num=NUM                    Maximum amount of photos to parse
    -a, --all                        Process all photos, not just previously unprocessed ones.
```

### Screenshot
!(screenshot)[https://img.skitch.com/20111016-pcsbme965fdjdhn4r3kc5kchu2.png]
