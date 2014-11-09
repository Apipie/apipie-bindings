Release notes
=============

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
