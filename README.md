This is just a quick preview...

This based on https://github.com/theforeman/foreman_api


Features
--------

#### Caching
The bindings cache the apidoc from the server. It has separated caches for each server it connects to. If the server sends apidoc hash in the headers ```Apipie-Apidoc-Hash: <md5>``` , the bindings can expire the cache and reload updated version before next request. If the server does not send the hashes, the cache does not expire and has to be deleted manually when necessary.

Sample patch for the server can be found here https://github.com/mbacovsky/foreman/commit/d35d76b9032bb3d3de2da7fb1dc780600eb08bdd

#### API introspection
It is possible to list available resources, actions, params, routes and its attributes

##### Getting started
```
$ rake install
$ irb
irb(main):003:0> require 'apipie_bindings'

irb(main):001:0> api = ApipieBindings::API.new({:uri => 'http://localhost:3000/', :username => 'admin', :password => :changeme})
```

##### Listing resources

```
irb(main):005:0> api.resources
=> [<Resource :roles>, <Resource :images>, <Resource :reports>, <Resource :hosts>, .... <Resource :architectures>]
```

##### Listing actions

```
irb(main):006:0> api.resource(:architectures).actions
=> [<Action :index>, <Action :show>, <Action :create>, <Action :update>, <Action :destroy>]
```

##### Listing routes
```
irb(main):008:0> api.resource(:architectures).action(:show).routes
=> [<Route /api/architectures/:id>]
```

##### Listing params

```
irb(main):007:0> api.resource(:architectures).action(:show).params
=> [<Param *id (String)>]


irb(main):009:0> api.resource(:architectures).action(:show).params.first.required?
=> true
```

##### Calling methods (all the calls bellow are equivalent)

```
irb(main):012:0> api.resource(:architectures).call(:show, :id => 1)
=> {"name"=>"x86_64", "id"=>1, "created_at"=>"2013-12-03T15:00:08Z", "updated_at"=>"2013-12-03T15:00:08Z"}

irb(main):013:0> api.call(:architectures, :show, :id => 1)
=> {"name"=>"x86_64", "id"=>1, "created_at"=>"2013-12-03T15:00:08Z", "updated_at"=>"2013-12-03T15:00:08Z"}

irb(main):014:0> api.resource(:architectures).action(:show).call(:id => 1)
=> {"name"=>"x86_64", "id"=>1, "created_at"=>"2013-12-03T15:00:08Z", "updated_at"=>"2013-12-03T15:00:08Z"}

```

TODO
----
* parameter validation
* better configurability
* error handling
* logging
* lots of other things
