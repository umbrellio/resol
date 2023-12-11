# frozen_string_literal: true

module Resol
  class Configuration
    DEFAULT_RETURN_ENGINE = ReturnEngine::Catch

    class << self
      def configure
        SmartCore::Initializer::Configuration.configure do |c|
          self.smartcore_config = c
          yield self
          self.smartcore_config = nil
        end
      end

      def return_engine
        @return_engine || DEFAULT_RETURN_ENGINE
      end

      def return_engine=(engine)
        @return_engine = engine
      end

      private

      attr_accessor :smartcore_config

      def method_missing(meth, *args, &block)
        # rubocop:disable Style/SafeNavigation
        if smartcore_config && smartcore_config.respond_to?(meth)
          # rubocop:enable Style/SafeNavigation
          smartcore_config.__send__(meth, *args, &block)
        else
          super(meth, *args, &block)
        end
      end

      def respond_to_missing?(meth, include_private)
        smartcore_config.respond_to?(meth, include_private)
      end
    end
  end
end
