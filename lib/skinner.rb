require "thor"
require 'fileutils'
require 'erb'
require 'test/unit'

require 'rubygems'
require 'curb'
require 'mocha'
Curl::Easy.stubs(:http_post).returns("class Something; end")

  gem_path = File.join(Dir["#{Gem.path.first}/gems/skinner*"].first, 'lib')
#  $:.unshift()
  Test::Unit.run=true #silence initial load of BuildCase base class
  %w(
  core_ext/*
  remote_build method_registry build_case
  ui/remote/*
  ).each do |glob_pattern|
    for path in Dir[File.join gem_path, glob_pattern]
      require path || path + ".rb"
    end
  end

class Skinner < Thor
  VERSION = "0.0.1"
  include Thor::Actions
  class Sandbox; end # some gem for a sandbox-env?

  desc "build my_model", "Generate a code file from the available buildcases/*"#, :required
  method_option :overwrite, :aliases => "-o", :type=>:string, :default=>"app/%s.%d.rb" #, :desc => 'outputs to a specific pattern containing a \d and \s, if given. Or the apps folder if otherwise not false.'
  method_options %w(alias -a) => :boolean
  method_options %w(preserve -p) => false
  def build(name)
    @name = name.underscore || "application"
    raise 'error' if buildsuite.tests.empty?
    contents = remote("build", buildsuite) 
        
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
  def buildfiles(glob_pattern, options={}, filters = [])
    Test::Unit.run = true
    $:.unshift glob_pattern.split("*").first
    if options[:inheritable]
      filters << proc {|filepath| unless(filepath =~ options[:inheritable]); true else; require(filepath); return(false) end }
    end
    Dir[glob_pattern].select do |filepath| 
      result = filters.inject(true) {|bool, filter| filter.call(filepath) && bool }
      block_given? ? yield(filepath, result) : result
    end
  end
  def buildsuite(options = {:from=>'buildcases/**/*.rb', :inheritable=>/build_case/})
    @buildcases ||= begin
      buildcases = buildfiles(options[:from], options)    
      raise ArgumentError if buildcases.empty?
      
      Test::Unit.run = false
      buildcases.inject(Test::Unit::TestSuite.new(project_name)) do |suite, buildcase| 

        eval(src = (File.read buildcase))
        klass = Skinner.const_get File.basename(buildcase).gsub(/(?:\.rb)/,'').camelize  
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
  rescue ArgumentError
    raise ArgumentError, "No buildcases found; Is there a directory '#{File.dirname options[:from]}' with some non-inheritable files?"
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
  require 'ruby-debug'
  # TODO: find out best approaches to 'register' various code elements to the app. (?)
  def register(response, pattern=nil)
    pattern ||= "app/%s.rb" 
    FileUtils.mkdir_p("app")
    file = block_given? ? yield(response, pattern) : save(response, pattern)
#    FileUtils.mv(file, "app")
  end
  def save(contents, pattern="%s.rb")
    debugger
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