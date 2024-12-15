# frozen_string_literal: true

module Resol
  class DependencyHandler
    extend Dry::Container::Mixin

    namespace(:external_libs) do
      register(:smartcore_injector, memoize: true) do
        require "smart_core/initializer"

        installer_proc = proc { include SmartCore::Initializer }
        Resol::Injector.new(installer_proc)
      end

      register(:dry_injector, memoize: true) do
        require "dry/initializer"

        installer_proc = proc { extend Dry::Initializer }
        Resol::Injector.new(installer_proc)
      end
    end

    namespace(:lib) do
      register(:plugin_manager) { Plugins::Manager.new }
    end
  end
end
