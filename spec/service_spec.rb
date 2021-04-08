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

RSpec.describe Resol::Service do
  it "returns a success result" do
    expect(SuccessService.call!).to eq(:success_result)
  end

  it "raises a failure result error" do
    expect { FailureService.call! }.to raise_error do |error|
      expect(error).is_a?(FailureService::Failure)
      expect(error.code).to eq(:failure_result)
      expect(error.data).to eq(data: 123)
    end
  end

  it "raises an unimplemented error" do
    expect { EmptyService.call! }.to raise_error do |error|
      expect(error).is_a?(EmptyService::InvalidCommandImplementation)
      expect(error.message).to eq("No success! or fail! called in the #call method in EmptyService")
    end
  end
end
