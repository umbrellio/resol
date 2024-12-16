# frozen_string_literal: true

require "dry-configurable"
require "dry-container"

module Resol
  extend self

  extend Dry::Configurable

  setting :classes_allowed_to_patch, default: ["Resol::Service"]
end

require_relative "resol/version"

require_relative "resol/injector"
require_relative "resol/plugins"
require_relative "resol/service"

require_relative "resol/dependency_container"
