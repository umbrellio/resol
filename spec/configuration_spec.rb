# frozen_string_literal: true

RSpec.describe Resol::Configuration do
  let(:cfg_values) { described_class.instance_variable_get(:@values) }

  it "properly configures" do
    expect(described_class.return_engine).to eq(described_class::DEFAULTS[:return_engine])
    expect(described_class.smart_config).to eq(SmartCore::Initializer::Configuration.config)

    described_class.return_engine = "kek"

    expect(described_class.return_engine).to eq("kek")
    expect(described_class.to_h.equal?(cfg_values)).to eq(false)
  end

  context "when undefined method is called" do
    specify do
      expect { described_class.kekpek }.to raise_error(NoMethodError)
    end
  end

  context "when smartcore not loaded" do
    before { allow(described_class).to receive(:smart_not_loaded?).and_return(true) }

    specify { expect(described_class.smart_config).to eq(nil) }
  end
end
