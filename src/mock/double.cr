module Mock
  class Double
    def initialize
      @stubs = Array(MethodStub).new
      @expectations = Array(MethodStub).new
      @negative_expectations = Array(MethodStub).new
      @calls = Array(MethodStub).new
      Mock.register self
    end

    def stub(method_name)
      MethodStub.new(method_name).tap do |stub|
        @stubs << stub
      end
    end

    def should_receive(method_name)
      stub(method_name).tap do |stub|
        @expectations << stub
      end
    end

    def should_not_receive(method_name)
      MethodStub.new(method_name).tap do |stub|
        @negative_expectations << stub
      end
    end

    def check_expectations
      @expectations.each do |expectation|
        @calls.find { |call| expectation.matches?(call) }.should CallExpectation.new(expectation)
      end
      @negative_expectations.each do |expectation|
        @calls.find { |call| expectation.matches?(call) }.should_not CallExpectation.new(expectation)
      end
    end

    macro method_missing(name, args, block)
      {% if args.empty? %}
        arguments = Arguments.empty
      {% else %}
        arguments = Arguments.new({{args}})
      {% end %}

      if stub = @stubs.find { |stub| stub.matches?(:{{name}}, arguments) }
        @calls << MethodStub.new(:{{name}}).with(arguments)
        stub.value
      else
        raise UnexpectedCall.new("Unexpected call to #{{{name}}}")
      end
    end
  end

  class CallExpectation
    def initialize(@expectation)
    end

    def match(call)
      call && call.matches?(@expectation)
    end

    def failure_message
      "expected #{@expectation.method_name} to be called with arguments #{@expectation.arguments.to_s}, but wasn't"
    end

    def negative_failure_message
      "expected #{@expectation.method_name} to not be called with arguments #{@expectation.arguments.to_s}, but was"
    end
  end
end
