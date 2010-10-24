require 'spec'
require 'mocha'
require 'ruby-debug'

require 'sunspot'
host, port = 'localhost', 8983
begin 
  TCPSocket.new(host, port)
rescue
  `sunspot-solr start`
  puts "That felt goooooood. Try that again!"
  exit(0)
end
Sunspot.config.solr.url = "http://#{host}:#{port}/solr" # TEST URL


#require 'sunspot_testcase'
=begin

/Users/jdarius/.rvm/gems/ruby-1.8.7-p299/gems/sunspot-1.1.0/lib/sunspot/type.rb
 303|    class BooleanType < AbstractType
 
def cast(string) #:nodoc:
  case string
  when 'true'
    true
  when 'false'
    false
  end
end
=end

require 'test/unit'
Sunspot.setup(Test::Unit::TestCase) do
  string  :class_name, :stored =>true, :multiple=>true
  text    :source,     :stored =>true
  boolean :passing,    :stored =>true
  boolean :failing,    :stored =>true
  boolean :erroring,   :stored =>true
end

Sunspot.remove_all!(Test::Unit::TestCase)

class TestAdapter < Sunspot::Adapters::InstanceAdapter
  def id; rand(100000000) end
end
Sunspot::Adapters::InstanceAdapter.register(TestAdapter, Test::Unit::TestCase)
#=end



Spec::Runner.configure do |config|
   config.mock_with :mocha
end

