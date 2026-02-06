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

    include Resol::Builder
    include Resol::Callbacks

    Result = Struct.new(:data)

    class << self
      def inherited(klass)
        klass.const_set(:Failure, Class.new(klass::Failure))
        super
      end

      # Allows you to configure an initializer library for this service,
      # such as `dry-initializer` or `smart_core/initializer`.
      #
      # @param initializer_name [String, Symbol]
      #   The name of the initializer (e.g., `:dry` or `:smart`).
      # @return [void]
      def use_initializer!(initializer_name)
        Resol::Injector.new(initializer_name).inject!(self)
      end

      def plugin(...)
        manager.plugin(self, ...)
      end

      # Calls the service using class-level invocation. Builds the service object,
      # runs any callbacks, and invokes the `#call` instance method.
      #
      # @param args [Array] Positional arguments for building service instance.
      # @param kwargs [Hash] Keyword arguments for building service instance.
      # @yield [block] An optional block passed into service's `#call`.
      #
      # @return [Resol::Success, Resol::Failure]
      #   Returns a `Resol::Success` if the service completed via `success!`,
      #   or a `Resol::Failure` if exited with`fail!` calling.
      #
      # @raise [InvalidCommandImplementation]
      #   If neither `#success!` nor `#fail!` is called inside the `#call` method.
      def call(*args, **kwargs, &)
        service = build(*args, **kwargs)

        result = handle_catch(service) do
          service.instance_variable_set(:@__performing__, true)
          __run_callbacks__(service)
          service.call(&)
        end
        return Resol::Success(result.data) if service.__result_method__called__

        error_message = "No `#success!` or `#fail!` called in `#call` method in #{service.class}."
        raise InvalidCommandImplementation, error_message
      rescue self::Failure => e
        Resol::Failure(e)
      end

      # Same as {call}, but attempts to resolve value from monad.
      # If the result is a failure, it raises the error instead of returning a `Resol::Failure`.
      #
      # @param args [Array]  Positional arguments for building the service instance.
      # @param kwargs [Hash] Keyword arguments for building the service instance.
      # @yield [block] An optional block passed to the service's `#call`.
      #
      # @return [Object]
      #   Returns a value, with which instance of service interrupts with {#success!}.
      #
      # @raise [self::Failure]
      #   Raises an error if the service fails.
      def call!(...)
        call(...).value_or { |error| raise error }
      end

      private

      def manager
        @manager ||= Plugins::Manager.new
      end

      def handle_catch(service, &)
        catch(service, &)
      end
    end

    attr_accessor :__result_method__called__

    private

    attr_reader :__performing__

    def fail!(code, data = nil)
      check_performing!
      raise self.class::Failure.new(code, data)
    end

    def success!(data = nil)
      check_performing!
      result_method_called!
      proceed_return(self, Result.new(data))
    end

    def check_performing!
      return if __performing__

      error_message =
        "It looks like #call instance method was called directly in #{self.class}. " \
        "You must always use class-level `.call` or `.call!` method."

      raise InvalidCommandCall, error_message
    end

    def result_method_called!
      self.__result_method__called__ = true
    end

    def proceed_return(service, data)
      throw(service, data)
    end
  end
end
