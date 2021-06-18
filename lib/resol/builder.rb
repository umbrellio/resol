# frozen_string_literal: true

module Resol
  module Builder
    def self.included(base)
      base.include(Uber::Builder)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def build_klass(...)
        klass = self

        loop do
          new_klass = klass.build!(klass, ...)
          break if new_klass == klass

          klass = new_klass
        end

        klass
      end

      def build(...)
        build_klass(...).new(...)
      end
    end
  end
end
