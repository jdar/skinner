#! /usr/bin/env ruby -rubygems
require 'spec/spec_helper'
require 'test/unit'
require 'skinner-radical'
Test::Unit::TestCase.send :include, Behavioralism

require 'working_apps/photo_app_1.rb'
class PhotoRankingTest < Test::Unit::TestCase
   def setup
    @photos = Hash.new {|h,k| h[k] = Photo.make }
       [10].each {|score| @photos[:highest_ranked].rankings.make(:score=>score) }
       [6,7,8].each {|score| @photos[:basic_photo].rankings.make(:score=>score) }
   end
   
   def test_highest_ranked_instance_of_photo
     photo = Photo.highest_ranked
     assert_equal Photo, photo.class
   end
   
   def test_instance_highest_ranked
     assert_equal 8, @photos[:basic_photo].highest_ranked
   end
  
   def test_highest_ranked
     expected_number = @photos.map {|key,p| p.rankings.max }.max.to_i
     assert_equal expected_number, Photo.highest_ranked.highest_ranked
   end
end



# TestCase will populate solr index on autorun: #
Test::Unit::AutoRunner.run
# remove_const :PhotoRankingTest ?
#######################


describe Behavioralism, "words" do
  it "index with detail" do
    s = Sunspot.search(Test::Unit::TestCase)
    s.hits.length.should == 6 # basic check
    s.hits.first # should have some heft to it.... > 50 characters??
  end  
end