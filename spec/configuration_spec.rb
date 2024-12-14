# frozen_string_literal: true

RSpec.describe Resol::Configuration do
  before { allow(described_class).to receive(:smart_not_loaded?).and_return(const_not_loaded?) }

  let(:const_not_loaded?) { true }

  it "#smart_config returns nil" do
    expect(described_class.smart_config).to eq(nil)
  end

  context "with loaded const" do
    let(:const_not_loaded?) { false }

    it "returns config" do
      expect(described_class.smart_config).to eq(SmartCore::Initializer::Configuration.config)
    end
  end

  context "with original method" do
    before { allow(described_class).to receive(:smart_not_loaded?).and_call_original }

    it "returns smartcore config" do
      expect(described_class.smart_config).to eq(SmartCore::Initializer::Configuration.config)
    end
  end
end
