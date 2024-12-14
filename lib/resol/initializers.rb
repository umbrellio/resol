# frozen_string_literal: true

module Resol
  module Initializers
    extend self

    MOD_MATCH_REGEX = /(Dry|SmartCore)::Initializer/

    def apply!(service_class, initializer_name)
      self.applied_classes ||= []
      validate_state!(service_class)

      case initializer_name
      when :smartcore
        require "smart_core/initializer"
        service_class.include(Object.const_get("SmartCore::Initializer"))
      when :dry
        require "dry/initializer"
        service_class.extend(Object.const_get("Dry::Initializer"))
      else
        raise ArgumentError, "unknown initializer #{initializer_name}"
      end
    end

    private

    attr_accessor :applied_classes

    def validate_state!(service_class)
      applied_parent = service_class
      return if service_class.ancestors.none? { |klass| klass.name.start_with?(MOD_MATCH_REGEX) }

      loop do
        applied_parent = applied_parent.superclass or break

        break if applied_classes.include?(applied_parent.name)
      end

      err_message = "#{applied_parent.name} or his superclasses manually include initializer dsl"
      raise ArgumentError, err_message
    end
  end
end
