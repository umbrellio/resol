# frozen_string_literal: true

RSpec.describe Resol::Plugins::Manager do
  let(:manager) { described_class.new(service_double) }

  let(:service_double) do
    class_double(
      Resol::Service, :DummyService, { prepend: true, singleton_class: singleton_double }
    )
  end

  let(:singleton_double) { double(prepend: true) }

  it "skips all prepends" do
    manager.plugin(:dummy)

    expect(service_double).not_to receive(:prepend)
    expect(singleton_double).not_to receive(:prepend)
  end

  context "when uses same plugin few times" do
    before { allow(manager).to receive(:resolve_module).and_return(Resol::Plugins::Dummy) }

    before { manager.plugin(:dummy) }

    let(:manager_plugins) { manager.instance_variable_get(:@plugins) }

    it "doesn't load plugin second time" do
      manager.plugin(:dummy)

      expect(manager).to have_received(:resolve_module).once
      expect(manager_plugins).to eq(["dummy"])
    end
  end

  context "when can't require plugin" do
    specify do
      expect { manager.plugin(:not_existed_plugin) }.to raise_error do |error|
        expect(error).to be_an_instance_of(ArgumentError)
        expect(error.message).to include("Failed to load plugin 'not_existed_plugin': ")
      end
    end
  end

  context "when can't resolve module" do
    before { allow(manager).to receive(:resolve_module).and_raise(NameError, "msg") }

    specify do
      expect { manager.plugin(:dummy) }.to raise_error do |error|
        expect(error).to be_an_instance_of(ArgumentError)
        expect(error.message).to include("Failed to load plugin 'dummy': msg")
      end
    end
  end
end
