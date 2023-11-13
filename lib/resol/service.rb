# frozen_string_literal: true

require_relative "builder"
require_relative "callbacks"
require_relative "result"

module Resol
  class Service
    class InvalidCommandImplementation < StandardError; end
    class InvalidCommandCall < StandardError; end

    class Failure < StandardError
      attr_accessor :data, :code

      def initialize(code, data)
        self.code = code
        self.data = data
        super(data)
      end

      def inspect
        "#{self.class.name}: #{message}"
      end

      def message
        data ? "#{code.inspect} => #{data.inspect}" : code.inspect
      end
    end

    include SmartCore::Initializer
    include Resol::Builder
    include Resol::Callbacks

    Result = Struct.new(:data)

    class << self
      def inherited(klass)
        klass.const_set(:Failure, Class.new(klass::Failure))
        super
      end

      def call(*args, **kwargs, &block)
        service = build(*args, **kwargs)

        result = return_engine.wrap_call(service) do
          service.instance_variable_set(:@__performing__, true)
          __run_callbacks__(service)
          service.call(&block)
        end

        if return_engine.uncaught_call?(result)
          error_message = "No `#success!` or `#fail!` called in `#call` method in #{service.class}."
          raise InvalidCommandImplementation, error_message
        else
          Resol::Success(result.data)
        end
      rescue self::Failure => e
        Resol::Failure(e)
      end

      def call!(...)
        call(...).value_or { |error| raise error }
      end
    end

    # @!method call

    private

    attr_reader :__performing__

    def fail!(code, data = nil)
      check_performing do
        raise self.class::Failure.new(code, data)
      end
    end

    def success!(data = nil)
      check_performing do
        return_engine.handle_return(self, Result.new(data))
      end
    end

    def check_performing
      if __performing__
        yield
      else
        error_message =
          "It looks like #call instance method was called directly in #{self.class}. " \
          "You must always use class-level `.call` or `.call!` method."

        raise InvalidCommandCall, error_message
      end
    end
  end
end
