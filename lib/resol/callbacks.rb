# frozen_string_literal: true

module Resol
  module Callbacks
    def self.included(base)
      base.extend(ClassMethods)
      base.instance_variable_set(:@__callback_methods__, [])
    end

    module ClassMethods
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@__callback_methods__, @__callback_methods__.dup)
      end

      def before_call(method_name)
        @__callback_methods__ << method_name
      end

      private

      def __run_callbacks__(instance)
        @__callback_methods__.each { |method_name| instance.__send__(method_name) }
      end
    end
  end
end
