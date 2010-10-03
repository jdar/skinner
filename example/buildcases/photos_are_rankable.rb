require 'buildcases/build_case_1'

class PhotosAreRankable < BuildCase1

  def test_photo_new_returns_photo
    Photo.new
  end

  def test_photo_instance_highest_ranked_returns_number
    photo = Photo.new
    assert Numeric > photo.highest_ranked
  end

  def test_photo_highest_ranked_returns_photo
    assert Numeric > Photo.highest_ranked
  end

  def test_photo_inherits_from_active_record
    assert ActiveRecord::Base > Photo
  end

end
