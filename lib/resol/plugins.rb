# frozen_string_literal: true

require "pathname"

module Resol
  module Plugins
    PLUGINS_PATH = Pathname("resol/plugins")
    class Manager
      def initialize
        self.plugins = []
      end

      def plugin(plugin_name)
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

      attr_accessor :plugins

      def find_plugin_module(plugin_name)
        require PLUGINS_PATH.join(plugin_name)
        Plugins.const_get(classify_plugin_name(plugin_name))
      rescue LoadError, NameError => e
        raise "Failed to load plugin '#{plugin_name}': #{e.message}"
      end

      def classify_plugin_name(string)
        string.split(/_|-/).map!(&:capitalize).join
      end

      def target_class
        Resol::Service
      end
    end
  end
end
