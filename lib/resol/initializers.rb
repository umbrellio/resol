# frozen_string_literal: true

module Resol
  module Initializers
    extend self

    INITIALIZER_ANCESTOR_REGEX = /(Dry|SmartCore)::Initializer/

    def apply!(service_class, initializer_name)
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

      (self.applied_classes ||= []) << service_class.name
    end

    private

    attr_accessor :applied_classes

    def validate_state!(service_class)
      applied_parent = nil
      service_class.ancestors.any? { |klass| klass.name.start_with?(INITIALIZER_ANCESTOR_REGEX) }

      loop do
        applied_parent = service_class.superclass or break

        break if applied_classes.key?(applied_parent.name)
      end

      if applied_parent.nil?
        err_message = "#{service_class.name} or his superclasses manually include initializer dsl"
        raise ArgumentError, err_message
      else
        raise ArgumentError, "initializer dsl already applied to #{applied_parent.name}"
      end
    end
  end
end
