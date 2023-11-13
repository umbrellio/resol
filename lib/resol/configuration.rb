# frozen_string_literal: true

module Resol
  class Configuration < Delegator
    DEFAULT_RETURN_ENGINE = ReturnEngine::Catch

    class << self
      def configure
        SmartCore::Initializer::Configuration.configure do |c|
          self.configurator = c
          yield self
        end
      end

      def return_engine
        @return_engine || DEFAULT_RETURN_ENGINE
      end

      def return_engine=(engine)
        @return_engine = engine
      end

      private

      attr_accessor :configurator

      def method_missing(meth, *args, &block)
        if configurator.respond_to?(target)
          configurator.__send__(meth, *args, &block)
        elsif ::Kernel.method_defined?(meth) || ::Kernel.private_method_defined?(meth)
          ::Kernel.instance_method(meth).bind_call(self, *args, &block)
        else
          super(meth, *args, &block)
        end
      end

      def respond_to_missing?(m, include_private)
        configurator.respond_to?(m, include_private)
      end
    end
  end
end
