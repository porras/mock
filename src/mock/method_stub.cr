module Mock
  class MethodStub
    getter :method_name, :arguments, :value

    def initialize(@method_name)
    end

    def with(arguments : Arguments)
      @arguments = arguments
      self
    end

    def with(*args)
      @arguments = if args.empty?
        Arguments.empty
      else
        Arguments.new(args)
      end

      self
    end

    def and_return(@value)
      self
    end

    def matches?(method_name, arguments)
      method_name == @method_name &&
        (@arguments.nil? || arguments.nil? || arguments == @arguments)
    end

    def matches?(other : MethodStub)
      matches?(other.method_name, other.arguments)
    end
  end
end
