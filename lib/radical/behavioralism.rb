require 'tempfile'
#to be included into Test::Unit::TestCase

# I implemented at Test level rather than suite level
# so it should be more portable to other testing libraries.
# an auto-runner extension is also in order.
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
  def class_name
    i = self.class.ancestors.rindex(Test::Unit::TestCase)
    self.class.ancestors[0..i]
  end
  def source; "not available: 'gem install ruby-internal'" end
  
  # bug! field.cast(true) in hit.rb:107 needs to re
#  return value if [true, false].include?(value)
# before>  sunspot-1.1.0/lib/sunspot/search/hit.rb130  return field.cast(value)
  
  def passing; @test_passed end
  alias :passing? :passing
  
  def failing; @test_passed == false end
  alias :failing? :failing
  
  def erroring; !!@errors end
  alias :erroring? :erroring
end

require 'method_registry'
module Behavioralism
  module IndexableSuite
    def tests_to_struct
      array_of_field_hashes = tests.inject([]) do |accum, test|
        fields = Hash.new{|h,k| h[k]=[]}
# ancestors
        test.class.ancestors[0..1].each {|ancestor|  proc{fields['class_name_ss']}.call << "#{ancestor}" }
# instance vars
#        instance_variables.each {|p| fields[p.delete("@")] = instance_variable_get(p) }
      
        accum << fields
      end
    end
    def to_xml # require 'builder'
      tests = self.tests_to_struct.
      inject("") do |tests,fields| 
          fields = fields.inject(""){|i,(k,vs)| vs.map {|v| i << "<field name='#{k}_ss'>#{v}</field>"}; i }
          tests << "<test>#{fields}</test>"
       end
      "<tests>#{tests}</tests>"
    end
                
    def behavioralist_index!
      url = "http://localhost:8983/solr"
#        require 'sunspot_testcase' #
        require 'sunspot'
        Sunspot.config.solr.url = url
        Sunspot.index!(self.tests) # require Sunspot.setup(base class) somewhere
=begin      
      rescue LoadError
        solr = RSolr.connect :url => url 
        solr.add tests_to_struct # :data => to_xml # rsolr >= ...
        solr.update '<commit/>'     
=end
    rescue
      # net/http to url...
    end
  end
end