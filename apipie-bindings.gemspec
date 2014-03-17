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
  s.license       = "GPL-3"

  s.summary       = %q{The Ruby bindings for Apipie documented APIs}
  s.description   = <<EOF
Bindings for API calls that are documented with Apipie. Bindings are generated on the fly.
EOF

  s.files            = `git ls-files -- {lib,bin,doc,config,test}/* README* LICENSE`.split("\n")
  s.test_files       = `git ls-files -- test/*`.split("\n")
  s.extra_rdoc_files = `git ls-files -- {doc,config}/* README*`.split("\n")
  s.has_rdoc         = 'yard'
  s.require_paths    = ["lib"]

  s.add_dependency 'json'
  s.add_dependency 'rest-client', '>= 1.6.1'
  s.add_dependency 'oauth'
  s.add_dependency 'i18n'
  s.add_dependency 'awesome_print'

end
