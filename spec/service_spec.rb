# frozen_string_literal: true

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

  context "with defined callbacks" do
    it "properly exectues them" do
      expect(ServiceWithCallbacks.call!).to eq("some_value")
    end
  end

  context "with inheritance" do
    let(:other_service) do
      Class.new(ServiceWithCallbacks) do
        before_call :set_other_value

        private

        def set_other_value
          @some_var += "_postfix"
        end
      end
    end

    it "properly handles inheritance" do
      expect(other_service.call!).to eq("some_value_postfix")
      expect(ServiceWithCallbacks.call!).to eq("some_value")
    end
  end
end
