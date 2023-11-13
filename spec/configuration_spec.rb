# frozen_string_literal: true

RSpec.describe Resol::Configuration do
  around do |example|
    example.call

    described_class.configure do |c|
      c.auto_cast = true
      c.return_engine = described_class::DEFAULT_RETURN_ENGINE
    end
  end

  it "delegates configuration" do
    described_class.configure do |c|
      c.auto_cast = false
      c.return_engine = Resol::ReturnEngine::Return
    end

    expect(SmartCore::Initializer::Configuration.config[:auto_cast]).to eq(false)
    expect(described_class.return_engine).to eq(Resol::ReturnEngine::Return)
  end
end
