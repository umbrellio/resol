# frozen_string_literal: true

RSpec.describe Resol::Initializers do
  def apply_initializer(forced_service_class = nil)
    described_class.apply!(forced_service_class || service_class, initializer_name)
  end

  before { stub_const("InitializerTestClass", service_class) }

  let(:service_class) do
    Class.new(Resol::Service) do
      def call
        success!
      end
    end
  end

  let(:initializer_name) { :dry }
  let(:dry_modules) do
    ["Dry::Initializer::Mixin::Root", start_with("Dry::Initializer::Mixin::Local")]
  end

  it "properly extend service class with initializer" do
    apply_initializer
    expect(service_class.ancestors.map(&:to_s)).to include(*dry_modules)
  end

  context "with unknown initializer lib" do
    let(:initializer_name) { :kek }

    specify do
      expect { apply_initializer }.to raise_error(ArgumentError, "unknown initializer kek")
    end
  end

  context "with already prepared parent" do
    before { stub_const("SecondChildService", second_child_service) }

    let(:service_class) do
      Class.new(ReturnEngineService) do
        def call
          success!
        end
      end
    end

    let(:second_child_service) do
      Class.new(InitializerTestClass)
    end

    let(:error_message) do
      "ReturnEngineService or his superclasses already used initialize lib"
    end

    specify do
      expect { apply_initializer(SecondChildService) }.to raise_error(ArgumentError, error_message)
    end
  end

  context "with manually extended service" do
    before { stub_const("SecondChildService", second_child_service) }

    let(:service_class) do
      Class.new(Resol::Service) do
        extend Dry::Initializer

        def call
          success!
        end
      end
    end

    let(:second_child_service) do
      Class.new(InitializerTestClass)
    end

    let(:error_message) { "use ::use_initializer! method on desired service class" }

    specify do
      expect { apply_initializer(SecondChildService) }.to raise_error(ArgumentError, error_message)
    end
  end
end
