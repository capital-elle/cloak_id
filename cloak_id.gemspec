# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloak_id/version'

Gem::Specification.new do |spec|
  spec.name          = "cloak_id"
  spec.version       = CloakId::VERSION
  spec.authors       = ["Elle L."]
  spec.email         = ["elle@pandromos.com"]
  spec.summary       = %q{Gem to help obfuscate Active Record ids.}
  spec.description   = %q{The cloak id gem allows developers to easily hide the actual (database) id of resources through obfuscation.}
  spec.homepage      = "https://github.com/elleleb/cloak_id"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rails","> 4.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "generator_spec"
end
