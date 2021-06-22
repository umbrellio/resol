# frozen_string_literal: true

class BaseService < Resol::Service
  param :type

  option :option

  builds { |type| ServiceA if type == :a }
  builds { |type| ServiceB if type == :b }
  builds { |*, option:| ServiceC if option }

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

class ServiceC < BaseService
  def call
    success!(:service_c)
  end
end

RSpec.describe Resol do
  it "builds a right service" do
    expect(BaseService.build(:a, option: true)).to be_a(ServiceA)
    expect(BaseService.build(:b, option: true)).to be_a(ServiceB)
    expect(BaseService.build(:other, option: false)).to be_a(BaseService)
    expect(BaseService.build(:other, option: true)).to be_a(ServiceC)
  end
end
