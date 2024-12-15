1# frozen_string_literal: true

module Resol
  class UnwrapError < StandardError; end

  # rubocop:disable Lint/EmptyClass
  class Result; end
  # rubocop:enable Lint/EmptyClass

  class Success < Result
    def initialize(value)
      super()
      @value = value
    end

    def success?
      true
    end

    def failure?
      false
    end

    def value_or(_other_value = nil)
      @value
    end

    def value!
      @value
    end

    def error = nil

    def or = nil

    def either(success_proc, _failure_proc)
      success_proc.call(@value)
    end

    def bind
      yield @value
    end

    def fmap(&)
      Resol.Success(bind(&))
    end
  end

  class Failure < Result
    def initialize(error)
      super()
      @value = error
    end

    def success?
      false
    end

    def failure?
      true
    end

    def value_or(other_value = nil)
      block_given? ? yield(@value) : other_value
    end

    def value!
      raise UnwrapError, "Failure result #{@value.inspect}"
    end

    def error
      @value
    end

    def or
      yield @value
    end

    def either(_success_proc, failure_proc)
      failure_proc.call(@value)
    end

    def bind = self

    alias fmap bind
  end
end
