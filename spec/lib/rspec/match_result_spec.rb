
require "rspec/match_result"

describe "#match_result" do
  let(:exp_not_met) {RSpec::Expectations::ExpectationNotMetError}

  # NOTE: We *generally* test error conditions before OK conditions here. Since we're testing a matcher, checking for `exp_not_met` is also a regular OK case.

  # A shortcut for a quoted <tt>Regexp</tt> constructor.
  #
  #   rx('expected: ["1", ".?", "/3/"]')  # etc.
  def rx(s)
    Regexp.new(Regexp.escape(s))
  end

  context "when value is expected" do
    it "generally works" do
      match_result("lala", "LALA") {|s| s.upcase}

      expect {
        match_result("lala", "LALAx") {|s| s.upcase}
      }.to raise_error(exp_not_met, rx('expected: ["lala", "LALAx"]'))
    end
  end

  context "when Class is expected" do
    context "when regular" do
      it "generally works" do
        match_result("lala", String) {|s| s.upcase}

        expect {
          match_result("lala", Integer) {|s| s.upcase}
        }.to raise_error(exp_not_met, rx('expected: ["lala", Integer]'))
      end
    end

    context "when Exception" do
      it "generally works" do
        match_result("lala", NoMethodError) {|s| s.no_such_method}

        expect {
          match_result("lala", ZeroDivisionError) {|s| s.no_such_method}
        }.to raise_error(exp_not_met, rx('undefined method `no_such_method\' for "lala":String'))
      end
    end
  end # context "when Class is expected"

  context "when Array is expected" do
    context "when [0] is a Class" do
      klass = Class.new do
        attr_accessor :i
        attr_accessor :s

        def initialize(attrs = {})
          attrs.each {|k, v| public_send("#{k}=", v)}
        end
      end

      it "generally works" do
        expect {
          match_result("lala", [String, 123]) {|s| s.upcase}
        }.to raise_error(ArgumentError, "Element 1 is not a Hash: 123")

        match_result("lala", [klass]) {|s| klass.new}
        match_result("lala", [klass, s: "LALA"]) {|s| klass.new(s: s.upcase)}
        match_result("lala", [klass, i: 4, s: "LALA"]) {|s| klass.new(i: s.size, s: s.upcase)}

        expect {
          match_result("lala", [klass, s: "LALAx"]) {|s| klass.new(s: s.upcase)}
        }.to raise_error(exp_not_met, rx('expected: ["lala", {:s=>"LALAx"}]'))

        expect {
          match_result("lala", [klass, no_such: "123"]) {|s| klass.new(s: s.upcase)}
        }.to raise_error(NoMethodError, /no_such/)
      end
    end

    context "when [0] is an Exception" do
      it "generally works" do
        expect {
          match_result("lala", [NoMethodError, 123]) {|s| s.no_such_method}
        }.to raise_error(ArgumentError, "Element 1 is not Regexp or String: 123")

        match_result("lala", [NoMethodError]) {|s| s.no_such_method}
        match_result("lala", [NoMethodError, 'undefined method `no_such_method\' for "lala":String']) {|s| s.no_such_method}
        match_result("lala", [NoMethodError, /undefined method.+no_such_method/]) {|s| s.no_such_method}

        expect {
          match_result("lala", [ZeroDivisionError, "xx"]) {|s| s.no_such_method}
        }.to raise_error(exp_not_met, rx('expected ZeroDivisionError with "xx"'))
      end
    end

    context "when other" do
      it "generally works" do
        expect {
          match_result("lala", [123]) {|s| s.upcase}
        }.to raise_error(ArgumentError, "Element 0 is not a Class: 123")
      end
    end
  end # context "when Array is expected"
end
