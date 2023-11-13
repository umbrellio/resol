# frozen_string_literal: true

module Resol
  module ReturnEngine
    module Return
      extend self

      def wrap_call(_service)
        yield
      end

      def uncaught_call?(return_obj)
        !return_obj.is_a?(Resol::Service::Result)
      end

      def handle_return(_service, data)
        data
      end
    end
  end
end
