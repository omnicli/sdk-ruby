# frozen_string_literal: true

require_relative "lib/omnicli/version"

Gem::Specification.new do |spec|
  spec.name          = "omnicli"
  spec.version       = OmniCli::VERSION
  spec.authors       = ["Raphaël Beamonte"]
  spec.email         = ["raphael.beamonte@gmail.com"]

  spec.summary       = "Ruby SDK for building Omni commands"
  spec.description   = "This package provides functionality to build Omni commands in Ruby"
  spec.homepage      = "https://omnicli.dev"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  unless spec.respond_to?(:metadata)
    raise "RubyGems 2.0 or newer is required to protect against public gem push vulnerabilities"
  end

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/omnicli/sdk-ruby"

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir.glob("{lib}/**/*") + %w[README.md LICENSE]
  spec.require_paths = ["lib"]

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
end
