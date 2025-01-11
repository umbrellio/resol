# frozen_string_literal: true

require "dry-configurable"
require_relative "resol/version"

require_relative "resol/injector"
require_relative "resol/plugins"
require_relative "resol/service"

module Resol
  extend self

  extend Dry::Configurable

  setting :classes_allowed_to_patch, default: ["Resol::Service"]
end
