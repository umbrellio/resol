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
          service.call.tap do |res|
            return Resol::Service::NOT_EXITED unless res.is_a?(Service::Result)
          end
        end
      end

      module InstanceMethods
        private

        def proceed_return(_service, data) = data
      end
    end
  end
end
