Release notes
=============

### 0.0.13 (2015-04-23)
* Limited rest-client versionto < 1.8.0
* Added option to turn off param validation (per call)
* Validation of optional parameters containing required attributes ([#24](https://github.com/Apipie/apipie-bindings/issues/24), [#25](https://github.com/Apipie/apipie-bindings/issues/25))

### 0.0.12 (2015-03-23)
* Add readme to the dummy app
* Fix ordering issue in tests
* Dummy app for testing purposes
* Declare 1.8 dependencies in Gemfile for tests
* Allow non-friendly 1.8 gems (Newer libraries supports IPv6)

### 0.0.11 (2014-11-09)
* Added lazy loading of credentials ([#7408](http://projects.theforeman.org/issues/7408))
* Separate caches for different API versions ([#18](http://github.com/Apipie/apipie-bindings/issues/18))
* Change license to MIT
* List missing parameter names in validation exception message

### 0.0.10 (2014-09-18)
* apipie-bindings should enforce required params, BZ 1116803 ([#6820](http://projects.theforeman.org/issues/6820))

### 0.0.9 (2014-08-29)
* Fixes RHBZ#1134954 - Log API errors that are re-risen with debug verbosity
* Add apidoc_cache_base_dir option to move all caches to another dir
* Moved development dependences to gemspec
* Fixed cache name test
* Added configuration for Travis CI
* Fixed response headers in dry_run
* Logging response headers
