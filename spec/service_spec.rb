# frozen_string_literal: true

class DB
  class << self
    attr_accessor :rollbacked

    def transaction
      self.rollbacked = false

      yield
      "return_some_val"
      # rubocop:disable Lint/RescueException
    rescue Exception
      # rubocop:enable Lint/RescueException
      self.rollbacked = true
      raise
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

class ServiceWithFailInTransaction < Resol::Service
  def call
    DB.transaction { fail!(:failed) }
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
    result = ServiceWithTransaction.call
    expect(result.success?).to eq(true)
    expect(result.value!).to eq(nil)
    expect(DB.rollbacked).to eq(false)
  end

  context "when service failed" do
    it "rollbacks transaction" do
      result = ServiceWithFailInTransaction.call
      expect(result.failure?).to eq(true)
      result.or do |error|
        expect(error.code).to eq(:failed)
      end

      expect(DB.rollbacked).to eq(true)
    end
  end
end
