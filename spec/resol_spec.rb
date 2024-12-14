# frozen_string_literal: true

RSpec.describe Resol do
  it "has a version number" do
    expect(Resol::VERSION).not_to be nil
  end

  describe "#config" do
    specify do
      expect(described_class.config).to eq(Resol::Configuration)
    end
  end

  describe "#configure" do
    specify do
      Resol.configure do |config|
        expect(config.smart_config).to eq(SmartCore::Initializer::Configuration.config)
      end
    end
  end
end
