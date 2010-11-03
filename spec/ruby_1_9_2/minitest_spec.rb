$:.unshift File.expand_path "#{File.dirname __FILE__}/../../spec"
require 'spec_helper'

unless RUBY_VERSION == "1.9.2"
  puts "not using the correct version of ruby" 
  exit(0)
end

begin
  require 'minitest/autorun'
  TestClass = MiniTest::Unit::TestCase
rescue
  raise "not using the expected test library"
end

def test_runner(action)
  s = PhotoRankingTest
  s.test_methods.map do |m| 
    begin
      s.new(m).run(s)
      puts "#{m} INDEXED"
    rescue 
      puts "#{m} SKIPPED" 
    end
  end
end

load 'radical_spec.rb'
# other library-specific tasks here?

