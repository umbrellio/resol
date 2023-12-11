# frozen_string_literal: true

module Resol
  module ReturnEngine
    NOT_EXITED = Object.new.freeze
    DataWrapper = Struct.new(:data)
  end
end

require_relative "return_engine/catch"
require_relative "return_engine/return"
