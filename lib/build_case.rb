class BuildCase < Test::Unit::TestCase
  class << self
    def suite; super.extend RemoteBuild end
#    include MethodRegistry
  end
   def run(result)
      yield(STARTED, name)
      @_result = result
      begin
        setup
        __send__(@method_name)
      rescue Test::Unit::AssertionFailedError => e
        add_failure(e.message, e.backtrace)
      rescue Exception
        raise if PASSTHROUGH_EXCEPTIONS.include? $!.class
        add_error($!)
      ensure
        begin
          teardown
        rescue AssertionFailedError => e
          add_failure(e.message, e.backtrace)
        rescue Exception
          raise if PASSTHROUGH_EXCEPTIONS.include? $!.class
          add_error($!)
        end
      end
      result.add_run
      yield(FINISHED, name)
    end
end
