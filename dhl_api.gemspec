# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dhl_api/version'

Gem::Specification.new do |spec|
  spec.name          = "dhl_api"
  spec.version       = DHLApi::VERSION
  spec.authors       = ["Bloom & Wild"]
  spec.email         = ["dev@bloomandwild.com"]

  spec.summary       = "Wrapper for DHL's SOAP API"
  spec.description   = "Wrapper for DHL's SOAP API"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "savon", "~> 2.11"
  spec.add_dependency "faraday", "~> 0.9"
  spec.add_dependency "httpclient", "~> 2.8.3"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "dotenv", "~> 2.0"

  # testing
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0.1"
  spec.add_development_dependency "vcr", "~> 3"
end
