# frozen_string_literal: true

require_relative "lib/resol/version"

Gem::Specification.new do |spec|
  spec.name          = "resol"
  spec.version       = Resol::VERSION
  spec.authors       = ["Aleksei Bespalov"]
  spec.email         = ["nulldefiner@gmail.com", "oss@umbrellio.biz"]

  spec.summary       = "Gem for creating (any) object patterns"
  spec.description   = "Gem for creating (any) object patterns"
  spec.homepage      = "https://github.com/umbrellio/resol"
  spec.license       = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")
  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(/spec/) }
  spec.require_paths = ["lib"]

  spec.add_dependency "smart_initializer"
  spec.add_dependency "uber"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-lcov"
end
