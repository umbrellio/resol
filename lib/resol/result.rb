# frozen_string_literal: true

module Resol
  class UnwrapError < StandardError; end

  class Result
    # @!method success?
    # @!method failure?
    # @!method value_or
    # @!method value!

    def initialize(*); end
  end

  class Success < Result
    def initialize(value)
      super
      @value = value
    end

    def success?
      true
    end

    def failure?
      false
    end

    def value_or(*)
      @value
    end

    def value!
      @value
    end
  end

  class Failure < Result
    def initialize(error)
      super
      @value = error
    end

    def success?
      false
    end

    def failure?
      true
    end

    def value_or(other_value = nil)
      if block_given?
        yield(@value)
      else
        other_value
      end
    end

    def value!
      raise UnwrapError, "Failure result #{@value.inspect}"
    end
  end

  def self.Success(*args)
    Success.new(*args)
  end

  def self.Failure(*args)
    Failure.new(*args)
  end
end
