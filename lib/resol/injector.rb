# frozen_string_literal: true

module Resol
  # The Injector class is responsible for injecting initialization logic provider.
  #
  # Supported providers:
  # - :smart -> uses the `smart_core/initializer`
  # - :dry   -> uses the `dry-initializer`
  class Injector
    InjectMarker = Module.new
    NAME_TO_METHOD_MAPPING = {
      smart: :inject_smart,
      dry: :inject_dry,
    }.freeze

    def self.inject_smart(service)
      require "smart_core/initializer"

      service.include(SmartCore::Initializer)
    end

    def self.inject_dry(service)
      require "dry/initializer"

      service.extend(Dry::Initializer)
    end

    def initialize(initializer_name)
      self.called_method = NAME_TO_METHOD_MAPPING.fetch(initializer_name.to_sym)
    end

    def inject!(service_class)
      error!("parent or this class already injected") if service_class.include?(InjectMarker)

      self.class.public_send(called_method, service_class)
      service_class.include(InjectMarker)
    end

    private

    attr_accessor :called_method

    def error!(msg)
      raise msg
    end
  end
end
