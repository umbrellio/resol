# frozen_string_literal: true

require "pathname"

module Resol
  module Plugins
    class Manager
      include Singleton

      def initialize
        self.patched_class = Resol::Service
        self.plugins = []
        self.plugin_lib_path = PathName("resol/plugins")
      end

      def plugin(plugin_name, ...)
        plugin_module = find_plugin_module(plugin_name)
        plugin_module.apply(target_class, ...) if plugin_module.respond_to?(:apply)

        if defined?(plugin_module::InstanceMethods)
          target_class.include(plugin_module::InstanceMethods)
        end

        if defined?(plugin_module::ClassMethods)
          target_class.extend(plugin_module::ClassMethods)
        end

        plugins << plugin_name
      end

      private

      attr_accessor :target_class, :plugins, :plugin_lib_path

      def find_plugin_module(plugin_name)
        require plugin_lib_path.join(plugin_name)
      rescue LoadError, NameError => e
        raise "Failed to load plugin '#{plugin_name}': #{e.message}"
      end

      def camel_case(string)
        string.split("_").map(&:capitalize).join
      end
    end
  end
end
