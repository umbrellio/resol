# frozen_string_literal: true

module Resol
  class Injector
    InjectMarker = Module.new

    def initialize(proc_register)
      self.proc_register = proc_register
    end

    def inject!(service_class)
      error!("parent or this class already injected") if service_class.is_a?(InjectMarker)

      service_class.instance_eval(&proc_register)
      service_class.include(InjectMarker)
    end

    private

    attr_accessor :proc_register

    def error!(msg)
       raise msg
    end
  end
end
