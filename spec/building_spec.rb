# frozen_string_literal: true

class BaseService < Resol::Service
  param :type

  builds { |type| ServiceA if type == :a }
  builds { |type| ServiceB if type == :b }

  def call
    success!(:base_service)
  end
end

class ServiceA < BaseService
  def call
    success!(:service_a)
  end
end

class ServiceB < BaseService
  def call
    success!(:service_b)
  end
end

RSpec.describe Resol do
  it "builds a right service" do
    expect(BaseService.build(:a)).to be_a(ServiceA)
    expect(BaseService.build(:b)).to be_a(ServiceB)
    expect(BaseService.build(:other)).to be_a(BaseService)
  end
end
