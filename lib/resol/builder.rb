# frozen_string_literal: true

module Resol
  module Builder
    def self.included(base)
      base.extend(ClassMethods)
    end

    class Builders < Array
      def call(initial_klass, *args, **kwargs)
        each do |block|
          klass = block.call(initial_klass, *args, **kwargs) and return klass
        end

        initial_klass
      end

      def <<(proc)
        wrapped = -> (ctx, *args, **kwargs) { ctx.instance_exec(*args, **kwargs, &proc) }
        super(wrapped)
      end
    end

    module ClassMethods
      def builders
        @builders ||= Builders.new
      end

      def builds(proc = nil, &block)
        builders << (proc || block)
      end

      def build_klass(*args, **kwargs)
        klass = self

        loop do
          new_klass = klass.builders.call(klass, *args, **kwargs)
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
