# frozen_string_literal: true

if ENV["COVER"]
  require "simplecov"
  require "simplecov-lcov"

  SimpleCov::Formatter::LcovFormatter.config do |config|
    config.report_with_single_file = true
    config.lcov_file_name = "lcov.info"
    config.output_directory = "coverage"
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter,
  ])

  SimpleCov.start do
    enable_coverage :branch
    minimum_coverage line: 100, branch: 100
    add_filter "spec"
  end
end

require "resol"
require "pry"

require "smart_core/initializer"
require "dry/initializer"

require "resol/plugins/dummy"

class SmartService < Resol::Service
  use_initializer! :smartcore
end

class ReturnEngineService < Resol::Service
  BASE_CLASS = self

  use_initializer! :dry

  class << self
    private

    def manager
      @manager ||= Resol::Plugins::Manager.new(self)
    end
  end
end

ReturnEngineService.plugin(:return_in_service)

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.order = :random
  Kernel.srand config.seed

  config.around do |ex|
    applied_classes = Resol::Initializers.send(:applied_classes).dup
    ex.call
    Resol::Initializers.send(:applied_classes=, applied_classes)
  end
end
