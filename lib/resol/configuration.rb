# frozen_string_literal: true

module Resol
  module Configuration
    extend self

    def smart_config
      return nil if smart_not_loaded?

      SmartCore::Initializer::Configuration.config
    end

    private

    def smart_not_loaded?
      !defined?(SmartCore::Initializer::Configuration)
    end
  end
end
