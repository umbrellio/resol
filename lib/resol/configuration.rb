# frozen_string_literal: true

module Resol
  module Configuration
    extend self

    DEFAULTS = { return_engine: Resol::ReturnEngine::Catch }.freeze

    DEFAULTS.each_key do |attr_name|
      define_method(attr_name) { values[attr_name] }
      define_method(:"#{attr_name}=") { |value| values[attr_name] = value }
    end

    def smart_config
      return nil if smart_not_loaded?

      SmartCore::Initializer::Configuration.config
    end

    def to_h = values.dup

    private

    def smart_not_loaded?
      !defined?(SmartCore::Initializer::Configuration)
    end

    def values
      @values ||= DEFAULTS.dup
    end
  end
end
