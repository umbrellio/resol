# frozen_string_literal: true

require_relative "builder"
require_relative "result"

module Resol
  class Service
    class InvalidCommandImplementation < StandardError; end

    class Interruption < StandardError
      attr_accessor :data

      def initialize(data)
        self.data = data
        super
      end

      def inspect
        "#{self.class.name}: #{message}"
      end

      def message
        data.inspect
      end
    end

    class Failure < Interruption
      attr_accessor :code

      def initialize(code, data)
        self.code = code
        super(data)
      end

      def message
        data ? "#{code.inspect} => #{data.inspect}" : code.inspect
      end
    end

    class Success < Interruption; end

    include SmartCore::Initializer
    include Resol::Builder

    class << self
      def inherited(klass)
        klass.const_set(:Failure, Class.new(klass::Failure))
        klass.const_set(:Success, Class.new(klass::Success))
        super
      end

      def call(*args, **options, &block)
        command = build(*args, **options)
        command.call(&block)

        error_message = "No success! or fail! called in the #call method in #{command.class}"
        raise InvalidCommandImplementation, error_message
      rescue self::Success => e
        Resol::Success(e.data)
      rescue self::Failure => e
        Resol::Failure(e)
      end

      def call!(*args)
        call(*args).value_or { |error| raise error }
      end
    end

    # @!method call

    private

    def fail!(code, data = nil)
      raise self.class::Failure.new(code, data)
    end

    def success!(data = nil)
      raise self.class::Success.new(data)
    end
  end
end
