
# Test level vs Suite level?
# portable to other testing libraries?
# auto-runner visualization?
class Test::Unit::TestSuite
  run = instance_method(:run)
  define_method :run do |*args, &blk|
    result = run.bind(self).call(*args, &blk)
    extend Behavioralism::IndexableSuite
    behavioralist_index!
    result
  end
end
class Test::Unit::TestCase
  attr_accessor :source  
  def class_name
    i = self.class.ancestors.rindex(Test::Unit::TestCase)
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
  
  def ruby_version; RUBY_VERSION end
end