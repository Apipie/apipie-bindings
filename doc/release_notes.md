Release notes
=============
### 0.2.2 (2018-01-09)
* modernize ruby versions ([PR #71](https://github.com/Apipie/apipie-bindings/pull/71))

### 0.2.1 (2018-01-06)
* Do not allow NIL as a route parameter ([PR #70](https://github.com/Apipie/apipie-bindings/pull/70)) ([#22009](http://projects.theforeman.org/issues/22009))
* update cache on error responses ([PR #67](https://github.com/Apipie/apipie-bindings/pull/67))
* pin oauth to support ruby < 2.0.0 ([PR #69](https://github.com/Apipie/apipie-bindings/pull/69))

### 0.2.0 (2017-04-24)
* Support for overriding exceptions from authorizers ([PR #64](https://github.com/Apipie/apipie-bindings/pull/64))
* Use ssl_ca_file with ssl_ca_path (rest-client < 1.7.0) ([PR #63](https://github.com/Apipie/apipie-bindings/pull/63)) ([#62](https://github.com/Apipie/apipie-bindings/issues/62))
* Make following redirects compatible with rest-client > 1.8 ([PR #61](https://github.com/Apipie/apipie-bindings/pull/61)) ([#60](https://github.com/Apipie/apipie-bindings/issues/60))

### 0.1.0 (2017-03-28)
* Verify SSL by default ([PR #59](https://github.com/Apipie/apipie-bindings/pull/59))
* Do not hide exceptions during cache retrieval ([PR #57](https://github.com/Apipie/apipie-bindings/pull/57))
* Legacy auth supports username config key ([PR #54](https://github.com/Apipie/apipie-bindings/pull/54))

### 0.0.19 (2016-12-09)
* Support for more advanced authentication algorithms ([PR #52](https://github.com/theforeman/apipie-bindings/pull/52))
* Show resource when inspecting Action ([PR #50](https://github.com/theforeman/apipie-bindings/pull/50))
* Prevent rest-client timeout deprecation warnings ([PR #53](https://github.com/theforeman/apipie-bindings/pull/53))

### 0.0.18 (2016-08-31)
* Recover from exception while inspecting error response ([#48](https://github.com/Apipie/apipie-bindings/issues/48))
* Add yard docs for ApipieBindings::Resource class ([#47](https://github.com/Apipie/apipie-bindings/issues/47))
* Restrict json to < 2.0.0 ([#46](https://github.com/Apipie/apipie-bindings/issues/46))
* Support rest-client 2.0.0 ([#45](https://github.com/Apipie/apipie-bindings/issues/45))

### 0.0.17 (2016-06-23)
* Restrict rest-client version to < 2.0.0 ([#42](https://github.com/Apipie/apipie-bindings/issues/42))
* Include request in response for rest-client < 1.8.0 ([#11147](http://projects.theforeman.org/issues/11147))
* Don't try to clear credentials if nil ([#43](https://github.com/Apipie/apipie-bindings/issues/43))

### 0.0.16 (2016-03-08)
* Controll following redirection ([#37](https://github.com/Apipie/apipie-bindings/issues/37))
* Enable for mocking api calls with validations
* Log the server uri ([#36](https://github.com/Apipie/apipie-bindings/issues/36))
* build without sudo ([#40](https://github.com/Apipie/apipie-bindings/issues/40))
* Added clear credentials on error ([#12112](http://projects.theforeman.org/issues/12112))
* Added a function that enables removing credentials on need ([#12112](http://projects.theforeman.org/issues/12112))

### 0.0.15 (2015-09-21)
* Make awesome_print optional ([#29](https://github.com/Apipie/apipie-bindings/issues/29))

### 0.0.14 (2015-08-25)
* support rest-client 1.8.0 ([#27](https://github.com/Apipie/apipie-bindings/issues/27))

### 0.0.13 (2015-04-23)
* Limited rest-client version to < 1.8.0
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
