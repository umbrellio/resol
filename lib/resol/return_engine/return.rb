# frozen_string_literal: true

module Resol
  module ReturnEngine
    module Return
      extend self

      DataWrapper = Struct.new(:data)

      def wrap_call(_service)
        yield
      end

      def uncaught_call?(return_obj)
        !return_obj.is_a?(DataWrapper)
      end

      def handle_return(_service, data)
        DataWrapper.new(data)
      end
    end
  end
end
