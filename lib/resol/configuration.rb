# frozen_string_literal: true

module Resol
  class Configuration
    DEFAULT_CONFIG_VALUES = { classes_allowed_to_patch: ["Resol::Service"] }.freeze

    def initialize
      self.data = DEFAULT_CONFIG_VALUES.deep_dup
    end

    DEFAULT_CONFIG_VALUES.each_key do |setting_name|
      define_method(setting_name) { data.fetch(setting_name) }
    end

    private

    attr_accessor :data
  end
end
