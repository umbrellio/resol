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

  context "when undefined method is called" do
    let(:called_block) do
      proc do
        described_class.configure do |c|
          c.not_exist = true
        end
      end
    end

    it "raises error" do
      expect(&called_block).to raise_error(NoMethodError)
    end
  end

  context "with undefined method" do
    it "respond_to? returns false" do
      expect(described_class.respond_to?(:not_exist)).to eq(false)
    end
  end
end
