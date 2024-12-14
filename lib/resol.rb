# frozen_string_literal: true

require_relative "resol/version"
require_relative "resol/return_engine"
require_relative "resol/configuration"
require_relative "resol/service"

module Resol
  extend self

  def config
    Configuration
  end

  def configure
    yield config
  end
end
