# frozen_string_literal: true

module Resol
  module Plugins
    module ReturnInService
      module ClassMethods
        private

        def handle_catch(_service)
          yield
        end

        def call_service(service)
          service.call.tap { |res| return unless res.is_a?(Service::Result) }
        end
      end

      module InstanceMethods
        private

        def proceed_return(_service, data) = data
      end
    end
  end
end
