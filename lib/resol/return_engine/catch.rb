# frozen_string_literal: true

module Resol
  module ReturnEngine
    module Catch
      extend self

      def wrap_call(service)
        catch(service) do
          yield
          NOT_EXITED
        end
      end

      def uncaught_call?(return_obj)
        return_obj == NOT_EXITED
      end

      def handle_return(service, data)
        throw(service, data)
      end
    end
  end
end
