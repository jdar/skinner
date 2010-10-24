require 'sunspot'
require 'test/unit'

Sunspot.setup(Test::Unit::TestCase) do
  string :class_name, :stored=>true, :multiple=>true
  string :source,     :stored =>true
end
Sunspot.remove_all!(Test::Unit::TestCase)

class TestAdapter < Sunspot::Adapters::InstanceAdapter
  def id; rand(100000000) end
end
Sunspot::Adapters::InstanceAdapter.register(TestAdapter, Test::Unit::TestCase)
