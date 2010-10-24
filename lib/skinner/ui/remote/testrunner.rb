require 'test/unit/ui/testrunnermediator'
require 'test/unit/ui/testrunnerutilities'
$:.unshift File.expand_path(File.dirname(__FILE__))
require 'pre_run'

module Test
  module Unit
    module UI
      module Remote
        # Runs a Test::Unit::TestSuite; outputs to remote URL.
        class TestRunner 
          extend TestRunnerUtilities
          extend PreRun

          def initialize(suite, output_level=NORMAL, io=STDOUT)
            if (suite.respond_to?(:suite))
              @suite = suite.suite
            else
              @suite = suite
            end
            @output_level = output_level
            @io = io
            @already_outputted = false
            @faults = []
          end

          # Begins the test run.
          def start
            setup_mediator
            attach_to_mediator
            return start_mediator
          end

          private
          def setup_mediator
            @mediator = create_mediator(@suite)
            suite_name = @suite.to_s
            if ( @suite.kind_of?(Module) )
              suite_name = @suite.name
            end
            output("Loaded suite #{suite_name}")
          end
          
          def create_mediator(suite)
            return TestRunnerMediator.new(suite)
          end
          
          def attach_to_mediator
            @mediator.add_listener(TestResult::FAULT, &method(:add_fault))
            @mediator.add_listener(TestRunnerMediator::STARTED, &method(:started))
            @mediator.add_listener(TestRunnerMediator::FINISHED, &method(:finished))
            @mediator.add_listener(TestCase::STARTED, &method(:test_started))
            @mediator.add_listener(TestCase::FINISHED, &method(:test_finished))
          end
          
          def start_mediator
            return @mediator.run_suite
          end
          
          def add_fault(fault)
            @faults << fault
            output_single(fault.single_character_display, PROGRESS_ONLY)
            @already_outputted = true
          end
          
          def started(result)
            @result = result
            output("Started")
          end
          
          def finished(elapsed_time)
            nl
            output("Finished in #{elapsed_time} seconds.")
            @faults.each_with_index do |fault, index|
              nl
              output("%3d) %s" % [index + 1, fault.long_display])
            end
            nl
            output(@result)
          end
          
          def test_started(name)
            output_single(name + ": ", VERBOSE)
          end
          
          def test_finished(name)
            output_single(".", PROGRESS_ONLY) unless (@already_outputted)
            nl(VERBOSE)
            @already_outputted = false
          end
          
          def nl(level=NORMAL)
            output("", level)
          end
          
          def output(something, level=NORMAL)
            @io.puts(something) if (output?(level))
            @io.flush
          end
          
          def output_single(something, level=NORMAL)
            @io.write(something) if (output?(level))
            @io.flush
          end
          
          def output?(level)
            level <= @output_level
          end
        end
      end
    end
  end
end

if __FILE__ == $0
  Test::Unit::UI::Remote::TestRunner.start_command_line_test
end
