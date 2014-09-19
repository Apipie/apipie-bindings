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
  s.has_rdoc         = 'yard'
  s.require_paths    = ["lib"]

  s.add_dependency 'json', '>= 1.2.1'
  s.add_dependency 'rest-client', '>= 1.6.5', '< 1.7' # lower versions don't allow setting infinite timeouts, higher versions are not ruby 1.8 compatible
  s.add_dependency 'oauth'
  s.add_dependency 'awesome_print'
  s.add_dependency 'mime-types', '~> 1.0'  #newer versions of mime-types are not 1.8 compatible

  s.add_development_dependency 'rake', '~> 10.1.0'
  s.add_development_dependency 'thor'
  s.add_development_dependency 'minitest', '4.7.4'
  s.add_development_dependency 'minitest-spec-context'
  s.add_development_dependency 'simplecov', '< 0.9.0' # 0.9.0 is not compatible with Ruby 1.8.x
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'ci_reporter', '>= 1.6.3', "< 2.0.0"

end
