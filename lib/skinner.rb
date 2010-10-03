require "thor"
require 'fileutils'
require 'erb'
require 'test/unit'

require 'rubygems'
require 'curb'
require 'ruby-debug'
require 'mocha'
Curl::Easy.stubs(:http_post).returns("class Something; end")


  $:.unshift File.expand_path(File.dirname(__FILE__))
  Test::Unit.run=true #silence initial load of BuildCase base class
  3.times { Dir.glob("lib/**/*.rb").each {|f| require f rescue nil }}
  raise 'whoops! try again. BuildCase dependecies not loaded' unless BuildCase.suite


class Skinner < Thor
  VERSION = "0.0.1"
  include Thor::Actions
  class Sandbox; end # some gem for a sandbox-env?

  desc "build my_model", "Generate a code file from the available buildcases/*"
  method_option :overwrite, :aliases => "-o" #, :desc => 'outputs to a specific pattern containing a \d and \s, if given. Or the apps folder if otherwise not false.'
  method_options %w(alias -a) => :boolean
  method_options %w(preserve -p) => :boolean, :default=>true
  def build(name)
    @name = name || "application"
    contents = remote("build", buildsuite) unless buildsuite.tests.empty?
        
    if app_file = register(contents, options[:overwrite]) {|code, pattern| save(code, pattern) }
      say_status :created, app_file
      if options[:alias]
#        `ln -nfs #{app_file}`
        say_status :aliased, app_file # hashrocket formating...
      end
      true
    else
      say "Unable to build #{name}"
      false
    end
  end

  desc "clean [my_model]", "Cleanup "
  method_options %w(re-alias -a) => :boolean, :default=>true
  def clean(name)
    if options[:alias]
#      `ln -nfs #{app_file}`
      say_status :'re-aliased', app_file # hashrocket formating...
    end
  end
#  alias clean cleanup

  def self.source_root
    "."
  end

protected
   # there has GOT to be a better way to blued this.
  def buildfiles(filepaths, options={}, filters = [])
    if options[:inheritable]
      filters << proc {|filepath| unless(filepath =~ options[:inheritable]); true else; require(filepath); return(false) end }
    end
    filepaths.select do |filepath| 
      result = filters.inject(true) {|bool, filter| filter.call(filepath) && bool }
      block_given? ? yield(filepath, result) : result
    end
  end
  def buildsuite(glob_pattern = 'buildcases/**/*.rb', options = {:inheritable=>/build_case/})
    Test::Unit.run = false
    $:.unshift glob_pattern.split("*").first
    buildfiles(Dir.glob(glob_pattern), options).
    inject(Test::Unit::TestSuite.new(project_name)) do |suite, buildcase| 

      src = (File.read buildcase)
      Skinner::Sandbox.class_eval(src)      
      klass = Skinner::Sandbox.const_get File.basename(buildcase).gsub(/(?:\.rb)/,'').camelize  
      klass.class_eval { attr_accessor :source }

      # extract into MethodRegistry?
      for test in klass.suite.tests
         case src
          when /def #{test.method_name};(.*?)end/, # support 1-line tests
               /(\s+)def #{test.method_name}(.*?)\n\1end/m   # OR find next 'end' with the same indentation
               test.source= $2.strip.split("\n").map{|l| l.strip + ";"}.join() rescue ""
          end
      end
      suite << klass.suite
    end
  end

  def app_file(name = nil, pattern=nil)
    # find my_model.rb
    return Dir["app/*.rb"].first if pattern.nil?

    # else my_model.54.rb
    pattern = pattern.is_a?(FalseClass) ? "app/*.*.rb" : pattern
    Dir[pattern].sort_by{|n| c = *n.match(/\d+/).captures }.last
  end

  def code
    @code ||=
      begin
        @code = eval(File.read(app_file))
      rescue Errno::ENOENT
        say_status :not_found, app_file
        exit 1
      end
  end

  def remote(method, suite)
    Curl::Easy.http_post("http://apigen.info/service") do |request|  
      Test::Unit::UI::Remote::TestRunner.pre_run(suite)
    end
  end
  
  # TODO: find out best approaches to 'register' various code elements to the app. (?)
  def register(response, pattern="app/%s.%d.rb")
    pattern ||= "app/%s.rb" 
    FileUtils.mkdir_p("app")
    file = block_given? ? yield(response, pattern) : response
#    FileUtils.mv(file, "app")
  end
  def save(contents, pattern="%s.rb")
    new_path = pattern % [@name, (i = (app_file(@name) =~ /\.(\d+)\.rb$/)[1] rescue 0)]
    File.open(new_path,"w") {|f| f.write contents }
    new_path
  end
  def project_name;  @name.gsub(/\W/,'').camelize end
  def test
    require @new_path
    Test::Unit::UI::Remote::TestRunner.run(suite)
  end
end
#Skinner.start(['build','my_model'])