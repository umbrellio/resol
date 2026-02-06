# frozen_string_literal: true

RSpec.describe Resol::Result do
  describe Resol::Success do
    let(:result) { Resol::Success(:success_value) }

    specify { expect(result.success?).to be_truthy }
    specify { expect(result.failure?).to be_falsey }
    specify { expect(result.value_or(:other_value)).to eq(:success_value) }
    specify { expect(result.value!).to eq(:success_value) }
    specify { expect(result.error).to be_nil }
    specify { expect { result.or { raise "Some Error" } }.not_to raise_error }

    specify do
      success_proc = instance_double(Proc)
      failure_proc = instance_double(Proc)
      allow(success_proc).to receive(:call).and_return("result")

      expect(result.either(success_proc, failure_proc)).to eq("result")
    end

    specify do
      final = result.bind(&:to_s)
      expect(final).to eq("success_value")
    end

    specify do
      final = result.bind do |val|
        Resol::Success("success").bind do |to_exclude|
          Resol::Success(val.to_s.gsub(to_exclude, ""))
        end
      end

      expect(final.success?).to eq(true)
      expect(final.value!).to eq("_value")
    end

    specify do
      final = result.fmap(&:to_s)

      expect(final.success?).to eq(true)
      expect(final.value!).to eq("success_value")
    end
  end

  describe Resol::Failure do
    let(:result) { Resol::Failure(:failure_value) }

    specify { expect(result.success?).to be_falsey }
    specify { expect(result.failure?).to be_truthy }
    specify { expect(result.value_or(:other_value)).to eq(:other_value) }
    specify { expect(result.error).to eq(:failure_value) }
    specify { expect { result.or { raise "Some Error" } }.to raise_error("Some Error") }

    specify do
      expect { result.value! }.to raise_error(Resol::UnwrapError, "Failure result :failure_value")
    end

    specify do
      success_proc = instance_double(Proc)
      failure_proc = instance_double(Proc)
      allow(failure_proc).to receive(:call).and_return("result")

      expect(result.either(success_proc, failure_proc)).to eq("result")
    end

    specify do
      final = result.bind(&:to_s)

      expect(final.failure?).to eq(true)
      expect(final.error).to eq(:failure_value)
    end

    specify do
      final = result.fmap { |val| val + 1 }

      expect(final.failure?).to eq(true)
      expect(final.error).to eq(:failure_value)
    end
  end
end
