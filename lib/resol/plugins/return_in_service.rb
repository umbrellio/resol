# frozen_string_literal: true

module Resol
  module Plugins
    module ReturnInService
      module ClassMethods
        private

        def handle_catch(_service)
          yield
        end
      end

      module InstanceMethods
        module PrependedMethods
          private

          def proceed_return(_service, data) = data
        end

        def self.included(service)
          service.prepend(PrependedMethods)
        end
      end
    end
  end
end
