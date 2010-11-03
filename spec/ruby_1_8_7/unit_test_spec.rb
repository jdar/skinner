$:.unshift File.expand_path "#{File.dirname __FILE__}/../../spec"
require 'rubygems'
require 'ruby-debug'

require 'spec_helper'

unless RUBY_VERSION == "1.8.7"
  puts "not using the correct version of ruby" 
  exit(0)
end

begin
  gem 'test-unit-full'
  require 'test/unit'
  require 'test/unit/ui/console/testrunner'
  TestClass = Test::Unit::TestCase
  TestRunnerClass = Test::Unit::UI::Console::TestRunner #Test::Unit::UI::Console::TestRunner
rescue
  raise "not using the expected test library"
end

def test_runner(action)
  pid = fork do
    STDERR.reopen('/dev/null')
    STDOUT.reopen('/dev/null')
    # (will still index results to server)
  end
  
  # raise your hand if you're a child?
  if $$ == pid 
    TestRunnerClass.run(PhotoRankingTest)
    Process.kill("TERM", $$)
  end
  Process.waitpid(pid)
  #  AutoRunnerClass.run false, nil, [[:silent,true]]
end


load 'radical_spec.rb'
# other library-specific tasks here?

