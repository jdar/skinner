require 'build_case'
class BuildCase1 < BuildCase 

  def test_truth
    assert true
  end
  
  def test_failure; assert true end
  
end
