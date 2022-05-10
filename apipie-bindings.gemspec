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

  s.add_dependency 'json', '>= 1.2.1'
  s.add_dependency 'rest-client', '>= 1.6.5', '< 3.0.0'      # lower versions don't allow setting infinite timeouts, higher versions have different api
  s.add_dependency 'oauth'
  s.add_dependency 'gssapi'
  s.add_development_dependency 'rake', '>= 12.3.3'
  s.add_development_dependency 'thor'
  s.add_development_dependency 'minitest', '4.7.4'
  s.add_development_dependency 'minitest-spec-context'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'ci_reporter', '>= 1.6.3', "< 2.0.0"

  s.required_ruby_version = '>= 2.0.0'
end
