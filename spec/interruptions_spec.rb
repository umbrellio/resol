# frozen_string_literal: true

RSpec.describe Resol::Service::Interruption do
  describe Resol::Service::Success do
    let(:object) { Resol::Service::Success.new(:some_data) }

    it { expect(object.inspect).to eq("Resol::Service::Success: :some_data") }
    it { expect(object.message).to eq(":some_data") }
  end

  describe Resol::Service::Failure do
    let(:object) { Resol::Service::Failure.new(:some_data, data) }

    context "without data" do
      let(:data) { nil }

      it { expect(object.inspect).to eq("Resol::Service::Failure: :some_data") }
      it { expect(object.message).to eq(":some_data") }
    end

    context "with data" do
      let(:data) { :data }

      it { expect(object.inspect).to eq("Resol::Service::Failure: :some_data => :data") }
      it { expect(object.message).to eq(":some_data => :data") }
    end
  end
end
