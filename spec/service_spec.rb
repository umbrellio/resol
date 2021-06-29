# frozen_string_literal: true

class DB
  class << self
    attr_accessor :rollbacked

    def transaction
      self.rollbacked = false

      yield
      # rubocop:disable Lint/RescueException
    rescue Exception
      # rubocop:enable Lint/RescueException
      self.rollbacked = true
    end
  end
end

class SuccessService < Resol::Service
  def call
    success!(:success_result)
  end
end

class FailureService < Resol::Service
  def call
    fail!(:failure_result, { data: 123 })
  end
end

class EmptyService < Resol::Service
  def call; end
end

class ServiceWithCallbacks < Resol::Service
  before_call :define_instance_var

  def call
    success!(@some_var)
  end

  private

  def define_instance_var
    @some_var = "some_value"
  end
end

class SubServiceWithCallbacks < ServiceWithCallbacks
  before_call :set_other_value

  private

  def set_other_value
    @some_var += "_postfix"
  end
end

class ServiceWithTransaction < Resol::Service
  def call
    DB.transaction { success! }
  end
end

RSpec.describe Resol::Service do
  it "returns a success result" do
    expect(SuccessService.call!).to eq(:success_result)
  end

  it "raises a failure result error" do
    expect { FailureService.call! }.to raise_error do |error|
      expect(error).to be_a(FailureService::Failure)
      expect(error.code).to eq(:failure_result)
      expect(error.data).to eq(data: 123)
    end
  end

  it "raises an unimplemented error" do
    expect { EmptyService.call! }.to raise_error do |error|
      expect(error).to be_a(EmptyService::InvalidCommandImplementation)
      expect(error.message).to eq("No success! or fail! called in the #call method in EmptyService")
    end
  end

  it "properly executes callbacks" do
    expect(SubServiceWithCallbacks.call!).to eq("some_value_postfix")
    expect(ServiceWithCallbacks.call!).to eq("some_value")
  end

  it "doesn't rollback transaction" do
    expect(ServiceWithTransaction.call!).to be_nil
    expect(DB.rollbacked).to eq(false)
  end
end
