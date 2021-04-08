# frozen_string_literal: true

RSpec.describe Resol::Result do
  describe Resol::Success do
    let(:result) { Resol::Success(:success_value) }

    it { expect(result.success?).to be_truthy }
    it { expect(result.failure?).to be_falsey }
    it { expect(result.value_or(:other_value)).to eq(:success_value) }
    it { expect(result.value!).to eq(:success_value) }
  end

  describe Resol::Failure do
    let(:result) { Resol::Failure(:failure_value) }

    it { expect(result.success?).to be_falsey }
    it { expect(result.failure?).to be_truthy }
    it { expect(result.value_or(:other_value)).to eq(:other_value) }
    it do
      expect { result.value! }.to raise_error(Resol::UnwrapError, "Failure result :failure_value")
    end
  end
end
