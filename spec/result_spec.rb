# frozen_string_literal: true

RSpec.describe Resol::Result do
  describe Resol::Success do
    let(:result) { Resol::Success(:success_value) }

    it { expect(result.success?).to be_truthy }
    it { expect(result.failure?).to be_falsey }
    it { expect(result.value_or(:other_value)).to eq(:success_value) }
    it { expect(result.value!).to eq(:success_value) }
    it { expect(result.error).to be_nil }
    it { expect { result.or { raise "Some Error" } }.not_to raise_error }

    it do
      success_proc = instance_double(Proc)
      failure_proc = instance_double(Proc)
      allow(success_proc).to receive(:call).and_return("result")

      expect(result.either(success_proc, failure_proc)).to eq("result")
    end
  end

  describe Resol::Failure do
    let(:result) { Resol::Failure(:failure_value) }

    it { expect(result.success?).to be_falsey }
    it { expect(result.failure?).to be_truthy }
    it { expect(result.value_or(:other_value)).to eq(:other_value) }
    it { expect(result.error).to eq(:failure_value) }
    it { expect { result.or { raise "Some Error" } }.to raise_error("Some Error") }

    it do
      expect { result.value! }.to raise_error(Resol::UnwrapError, "Failure result :failure_value")
    end

    it do
      success_proc = instance_double(Proc)
      failure_proc = instance_double(Proc)
      allow(failure_proc).to receive(:call).and_return("result")

      expect(result.either(success_proc, failure_proc)).to eq("result")
    end
  end
end
