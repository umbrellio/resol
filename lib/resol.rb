# frozen_string_literal: true

require "dry-container"

require_relative "resol/version"
require_relative "resol/configuration"

require_relative "resol/injector"
require_relative "resol/service"
require_relative "resol/plugins"
require_relative "resol/dependency_container"

module Resol
  extend self

  def config
    @config ||= Configuration.new
  end

  # rubocop:disable Naming/MethodName
  def Success(...)
    Success.new(...)
  end

  def Failure(...)
    Failure.new(...)
  end
  # rubocop:enable Naming/MethodName
end
