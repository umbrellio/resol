# frozen_string_literal: true

require "pathname"

module Resol
  module Plugins
    PLUGINS_PATH = Pathname("resol/plugins")
    class Manager
      def self.resolve_module(module_name)
        Plugins.const_get(module_name)
      end

      def initialize
        self.allowed_classes = resolve_allowed_classes
        self.plugins = []
      end

      def plugin(caller_class, plugin_name)
        plugin_name = plugin_name.to_s

        return unless allowed_classes.include?(caller_class)
        return if plugins.include?(plugin_name)

        plugin_module = find_plugin_module(plugin_name)
        if defined?(plugin_module::InstanceMethods)
          caller_class.prepend(plugin_module::InstanceMethods)
        end

        if defined?(plugin_module::ClassMethods)
          caller_class.singleton_class.prepend(plugin_module::ClassMethods)
        end

        plugins << plugin_name
      end

      private

      attr_accessor :allowed_classes, :plugins

      def resolve_allowed_classes
        Resol.config.classes_allowed_to_patch.map { |name| Object.const_get(name) }
      end

      def find_plugin_module(plugin_name)
        require PLUGINS_PATH.join(plugin_name)
        self.class.resolve_module(classify_plugin_name(plugin_name))
      rescue LoadError, NameError => e
        raise ArgumentError, "Failed to load plugin '#{plugin_name}': #{e.message}"
      end

      def classify_plugin_name(string)
        string.split(/_|-/).map!(&:capitalize).join
      end
    end
  end
end
