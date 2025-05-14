# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "apipie_bindings/version"

Gem::Specification.new do |s|

  s.name          = "apipie-bindings"
  s.version       = ApipieBindings.version.dup
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Martin Bačovský"]
  s.email         = "mbacovsk@redhat.com"
  s.homepage      = "http://github.com/Apipie/apipie-bindings"
  s.license       = "MIT"

  s.summary       = %q{The Ruby bindings for Apipie documented APIs}
  s.description   = <<EOF
Bindings for API calls that are documented with Apipie. Bindings are generated on the fly.
EOF

  s.files            = `git ls-files -- {lib,bin,doc,config,test}/* README* LICENSE`.split("\n")
  s.test_files       = `git ls-files -- test/*`.split("\n")
  s.extra_rdoc_files = `git ls-files -- {doc,config}/* README*`.split("\n")
  s.require_paths    = ["lib"]

  s.add_dependency 'rest-client', '~> 2.0'
  s.add_dependency 'oauth', '~> 1.1'
  s.add_dependency 'gssapi', '~> 1.2'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'minitest', '~> 4.7'
  s.add_development_dependency 'minitest-spec-context', '~> 0.0.5'
  s.add_development_dependency 'simplecov', '~> 0.22'
  s.add_development_dependency 'mocha', '~> 2.7'

  s.required_ruby_version = '>= 2.7.0'
end
