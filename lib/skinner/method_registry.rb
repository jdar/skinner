Test::Unit::TestSuite.class_eval do 
   attr_accessor :source
   alias_method :run_without_registry, :run
   def run_with_registry(*args, &blk)
     debugger if source # ?
     result = run_without_registry(*args, &blk)
     result
   end
   alias_method :run, :run_with_registry
 end
 
Test::Unit::TestCase.class_eval do
   attr_accessor :source # body of test
   def method_added(method)
     if suite.source
       case suite.source
        when /def #{test.method_name};(.*?)[^\n](?:\W+)end/, # support 1-line tests
             /(\s+)def #{test.method_name}(.*?)\n\1end/m   # OR find next 'end' with the same indentation
             self.source= $2.strip.split("\n").map{|l| l.strip + ";"}.join() rescue nil
        end
     end
     super
   end 
end
 
module MethodRegistry
  def self.included(base)
    
  end
  
  def self.register_source(source = nil)
    testcases ||= Dir[] # Dir['path/to/test/files/*']
    Test::Unit.run = false
    testcases.inject(Test::Unit::TestSuite.new(project_name)) do |suite, testcase| 

      eval(src = (File.read testcase))
      klass = self.class.const_get File.basename(testcase).gsub(/(?:\.rb)/,'').camelize  

      # extract into MethodRegistry?
      for test in klass.suite.tests
         
      end
      suite << klass.suite
    end
  end


  # borrowed: http://pivotallabs.com/users/cheister/blog/articles/659-duplicate-test-name-detection
  def known_test_methods
    @known_test_methods ||= Array.new
  end

=begin
  def method_added(method)
    if method.to_s.match /^test./
      if known_test_methods.include?(method)
        raise "Duplicate test #{self}##{method}"
      else
        known_test_methods << method
      end
    end
    super
  end
=end
end