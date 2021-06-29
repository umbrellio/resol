# frozen_string_literal: true

require_relative "builder"
require_relative "callbacks"
require_relative "result"

module Resol
  class Service
    class InvalidCommandImplementation < StandardError; end

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

    SUCCESS_TAG = Object.new.freeze
    Result = Struct.new(:data)

    class << self
      def inherited(klass)
        klass.const_set(:Failure, Class.new(klass::Failure))
        super
      end

      def call(*args, **kwargs, &block)
        command = build(*args, **kwargs)
        result = catch(SUCCESS_TAG) do
          __run_callbacks__(command)
          command.call(&block)
        end
        return Resol::Success(result.data) unless result.nil?

        error_message = "No success! or fail! called in the #call method in #{command.class}"
        raise InvalidCommandImplementation, error_message
      rescue self::Failure => e
        Resol::Failure(e)
      end

      def call!(...)
        call(...).value_or { |error| raise error }
      end
    end

    # @!method call

    private

    def fail!(code, data = nil)
      raise self.class::Failure.new(code, data)
    end

    def success!(data = nil)
      throw(SUCCESS_TAG, Result.new(data))
    end
  end
end
