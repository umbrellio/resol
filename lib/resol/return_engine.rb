# frozen_string_literal: true

module Resol
  module ReturnEngine
    NOT_EXITED = Object.new.freeze
  end

  require_relative "return_engine/catch"
  require_relative "return_engine/return"
end
