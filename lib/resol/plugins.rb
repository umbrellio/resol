# frozen_string_literal: true

require "pathname"

module Resol
  module Plugins
    PLUGINS_PATH = Pathname("resol/plugins")
    class Manager
      def initialize(target_class = nil)
        self.plugins = []
        self.target_class = target_class || Resol::Service
      end

      def plugin(plugin_name)
        plugin_name = plugin_name.to_s
        return if plugins.include?(plugin_name)

        plugin_module = find_plugin_module(plugin_name)
        if defined?(plugin_module::InstanceMethods)
          target_class.prepend(plugin_module::InstanceMethods)
        end

        if defined?(plugin_module::ClassMethods)
          target_class.singleton_class.prepend(plugin_module::ClassMethods)
        end

        plugins << plugin_name
      end

      private

      attr_accessor :plugins, :target_class

      def find_plugin_module(plugin_name)
        require PLUGINS_PATH.join(plugin_name)
        resolve_module(classify_plugin_name(plugin_name))
      rescue LoadError, NameError => e
        raise ArgumentError, "Failed to load plugin '#{plugin_name}': #{e.message}"
      end

      def resolve_module(module_name)
        Plugins.const_get(module_name)
      end

      def classify_plugin_name(string)
        string.split(/_|-/).map!(&:capitalize).join
      end
    end
  end
end
