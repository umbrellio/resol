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

    module ChildMethodRestriction
      def plugin(*)
        raise NoMethodError
      end

      def manager
        raise NoMethodError
      end
    end

    include Resol::Builder
    include Resol::Callbacks

    Result = Struct.new(:data)
    NOT_EXITED = Object.new.freeze

    class << self
      def inherited(klass)
        klass.const_set(:Failure, Class.new(klass::Failure))
        klass.extend(ChildMethodRestriction)
        super
      end

      def use_initializer!(initializer_lib)
        Initializers.apply!(self, initializer_lib)
      end

      def plugin(...)
        manager.plugin(...)
      end

      def call(*, **)
        service = build(*, **)

        result = handle_catch(service) do
          service.instance_variable_set(:@__performing__, true)
          __run_callbacks__(service)
          call_service(service)
        end

        if result == NOT_EXITED
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

      private

      def manager
        @manager ||= Plugins::Manager.new
      end

      def handle_catch(service)
        catch(service) do
          yield
          NOT_EXITED
        end
      end

      def call_service(service)
        service.call
        NOT_EXITED
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
        proceed_return(self, Result.new(data))
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

    def proceed_return(data)
      throw(self, data)
    end
  end
end
