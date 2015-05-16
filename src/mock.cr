require "./mock/spec_fix"
require "./mock/*"

module Mock
  class UnexpectedCall < Exception
  end

  class DoublesRegistry
    def initialize
      @doubles = [] of Mock::Double
    end

    delegate :<<, @doubles

    def reset
      @doubles.clear
    end

    def each
      @doubles.each do |double|
        yield double
      end
    end
  end

  @@doubles = DoublesRegistry.new

  def self.register(double)
    @@doubles << double
  end

  def self.reset
    @@doubles.reset
  end

  def self.registry
    @@doubles
  end
end

Spec.before_each do
  Mock.reset
end

Spec.after_each do
  Mock.registry.each do |double|
    double.check_expectations
  end
end

def double(*args)
  Mock::Double.new(*args)
end
