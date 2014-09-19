Apipie Bindings
===============

The Ruby bindings for Apipie documented APIs.

Features
--------

#### Caching
The bindings cache the apidoc from the server. It has separated caches for each server it connects to. If the server sends the apipie checksum in the headers ```Apipie-Checksum: <md5>``` , the bindings can expire the cache and reload updated version before next request. If the server does not send the hashes, the cache does not expire and has to be deleted manually when necessary.

The ability to send checksums comes with Apipie 0.1.1, see the [docs](https://github.com/Apipie/apipie-rails#json-checksums) on how to set it up.

#### API introspection
It is possible to list available resources, actions, params, routes and its attributes

##### Getting started
```
$ rake install
$ irb
irb> require 'apipie-bindings'

irb> api = ApipieBindings::API.new({:uri => 'http://localhost:3000/', :username => 'admin', :password => :changeme})
```

##### Listing resources

```
irb> api.resources
=> [<Resource :roles>, <Resource :images>, <Resource :reports>, <Resource :hosts>, .... <Resource :architectures>]
```

##### Listing actions

```
irb> api.resource(:architectures).actions
=> [<Action :index>, <Action :show>, <Action :create>, <Action :update>, <Action :destroy>]
```

##### Listing routes
```
irb> api.resource(:architectures).action(:show).routes
=> [<Route /api/architectures/:id>]
```

##### Listing params

```
irb> api.resource(:architectures).action(:show).params
=> [<Param *id (String)>]


irb> api.resource(:architectures).action(:show).params.first.required?
=> true
```

##### Calling methods (all the calls bellow are equivalent)

```
irb> api.resource(:architectures).call(:show, :id => 1)
=> {"name"=>"x86_64", "id"=>1, "created_at"=>"2013-12-03T15:00:08Z", "updated_at"=>"2013-12-03T15:00:08Z"}

irb> api.call(:architectures, :show, :id => 1)
=> {"name"=>"x86_64", "id"=>1, "created_at"=>"2013-12-03T15:00:08Z", "updated_at"=>"2013-12-03T15:00:08Z"}

irb> api.resource(:architectures).action(:show).call(:id => 1)
=> {"name"=>"x86_64", "id"=>1, "created_at"=>"2013-12-03T15:00:08Z", "updated_at"=>"2013-12-03T15:00:08Z"}

```

Documentation
-------------
there is not much of the library documented yet, but we started to document our API with Yard.
The docs are installed with the gem and can be viewed from the docs dir directly or by running
```yard server --gems``` or **online** on [rubydoc.info](http://rubydoc.info/github/Apipie/apipie-bindings/)


TODO
----
* parameter validation
* update docs


License
-------

This project is licensed under the MIT license.
