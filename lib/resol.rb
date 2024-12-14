# frozen_string_literal: true

require_relative "resol/version"
require_relative "resol/configuration"
require_relative "resol/initializers"
require_relative "resol/service"
require_relative "resol/plugins"

module Resol
  extend self

  def config
    Configuration
  end

  def configure
    yield config
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
