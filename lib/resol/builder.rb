# frozen_string_literal: true

module Resol
  module Builder
    def self.included(base)
      base.include(Uber::Builder)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def build_klass(*args)
        klass = self

        loop do
          new_klass = klass.build!(klass, *args)
          break if new_klass == klass

          klass = new_klass
        end

        klass
      end

      def build(*args)
        build_klass(*args).new(*args)
      end
    end
  end
end
