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

      def inject_initializer!(injector_name)
        injector = DependencyContainer.resolve("external_libs.#{injector_name}")
        injector.inject!(self)
      end

      def plugin(...)
        manager.plugin(self, ...)
      end

      def call(...)
        service = build(...)

        result = handle_catch(service) do
          service.instance_variable_set(:@__performing__, true)
          __run_callbacks__(service)
          service.call
        end
        return Resol::Success(result.data) if service.__result_method__called__

        error_message = "No `#success!` or `#fail!` called in `#call` method in #{service.class}."
        raise InvalidCommandImplementation, error_message
      rescue self::Failure => e
        Resol::Failure(e)
      end

      def call!(...)
        call(...).value_or { |error| raise error }
      end

      private

      def manager
        @manager ||= DependencyContainer.resolve("lib.plugin_manager")
      end

      def handle_catch(service, &)
        catch(service, &)
      end
    end

    # @!method call

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
