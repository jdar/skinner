
# Test level vs Suite level?
# portable to other testing libraries?
# auto-runner visualization?
class Minitest::TestCase
  attr_accessor :source
  def class_name
    i = self.class.ancestors.rindex(Minitest::TestCase)
    self.class.ancestors[0..i]
  end  
# bug! BooleanType.cast(true) in sunspot/lib/sunspot/type.rb
#  case string ... => when true, "true"; true
  def source
    "5+5+5"
  end
  def passing; @test_passed end
  alias :passing? :passing
  
  def failing; @test_passed == false end
  alias :failing? :failing
  
  def erroring; !!@errors end
  alias :erroring? :erroring
end