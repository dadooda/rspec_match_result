
require "rspec"

module RSpec
  module MatchResult
    module Helpers
      # Feed <tt>input</tt> to <tt>block</tt> and match block result against <tt>expected</tt>.
      #
      #   match_result(input, "LALA") {...}                     # Match value.
      #   match_result(input, Klass) {...}                      # Match instance class.
      #   match_result(input, ErrorKlass) {...}                 # Match exception.
      #   match_result(input, [Klass, name: "Joe"]] {...}       # Match instance class and selected attributes.
      #   match_result(input, [ErrorKlass, /message/]] {...}    # Match exception and message.
      def match_result(input, expected, &block)
        raise ArgumentError, "Code block expected" if not block

        result = -> {yield(input)}

        case expected
        when Class
          if (klass = expected) < Exception
            expect {
              result[]
            }.to raise_error(klass)
          else
            # Match regular class.
            expect([input, result[].class]).to eq [input, klass]
          end
        when Array
          klass = expected[0]
          raise ArgumentError, "Element 0 is not a Class: #{klass.inspect}" if not klass.is_a? Class

          if klass < Exception
            expected_message = expected[1]

            args = if expected_message
              [expected_message, [Regexp, String]].tap {|v, klasses| klasses.any? {|klass| v.is_a? klass} or raise ArgumentError, "Element 1 is not #{klasses.join(' or ')}: #{v.inspect}"}
              [klass, expected_message]
            else
              [klass]
            end

            expect {
              result[]
            }.to raise_error(*args)
          else
            # Regular class.
            expected_attrs = expected[1] || {}   # Allow `[Klass]`.
            raise ArgumentError, "Element 1 is not a Hash: #{expected_attrs.inspect}" if not expected_attrs.is_a? Hash

            # Match class before fetching attributes.
            expect([input, (value = result[]).class]).to eq [input, klass]

            result_attrs = Hash[*expected_attrs.keys.map {|k| [k, value.send(k)]}.flatten(1)]
            expect([input, result_attrs]).to eq [input, expected_attrs]
          end
        else
          # Match value.
          expect([input, result[]]).to eq [input, expected]
        end
      end
    end
  end
end

RSpec.configure do |config|
  include RSpec::MatchResult::Helpers
end
