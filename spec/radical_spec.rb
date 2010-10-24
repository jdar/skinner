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
   
   def test_incomplete_functionality
     assert false
   end
   
   def test_uncaught_erroring
     # throw an error type and rescue in testcase for testing?
     raise RuntimeError, "This TestCase error invoked intentionally. Look below for real errors (RSpec errors). "
   end
   def test_erroring
     assert_raise RuntimeError do
       raise RuntimeError, "This TestCase error invoked intentionally AND CAUGHT. "
     end
   end
end



# TestCase will populate solr index on autorun: #
Test::Unit::AutoRunner.run
# remove_const :PhotoRankingTest ?
#######################


describe Behavioralism do
  it "indexes all tests" do
    s = Sunspot.search(Test::Unit::TestCase)
    s.hits.length.should == 6
  end
  
  it "flags failing and erroring tests" do
    s = Sunspot.search(Test::Unit::TestCase) { with(:passing, true) }
    s.hits.length.should == 4
  end
  
  it "has metadata" do
    s = Sunspot.search(Test::Unit::TestCase) { with(:passing, true) }
    hit = s.hits.first
    hit.stored(:passing).should == true
    hit.stored(:class_name).should == ["PhotoRankingTest","Test::Unit::TestCase"]
  end
  
  it "searchable by ancestor class_name" do
    s = Sunspot.search(Test::Unit::TestCase) { with(:class_name, "PhotoRankingTest") }
    s.hits.any?.should be_true
  end
  
  it "searchable by class_name OR parent class name" do
    # equivalence test not possible: id numbers's are regenerated randomly.
    Sunspot.search(   Test::Unit::TestCase  ).hits.length.should == 
    Sunspot.search(   PhotoRankingTest      ).hits.length
  end
  
end