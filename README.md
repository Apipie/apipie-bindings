This is just a quick preview...

This based on https://github.com/theforeman/foreman_api

```
$ rake install
$ irb
irb(main):001:0> require 'apipie_bindings'
=> true
irb(main):002:0> api = ApipieBindings::API.new({:uri => 'http://192.168.122.114:3000/', :username => 'admin', :password => 'changeme'})
=> #<ApipieBindings::API:0x00000002273308 @apidoc_cache_dir="/tmp/apipie_bindings/http___192.168.122.114_3000_", @apidoc_cache_file="/tmp/apipie_bindings/http___192.168.122.114_3000_/apidoc.json", @api_version=2, @client=#<RestClient::Resource:0x00000002272ef8 @url="http://192.168.122.114:3000/", @block=nil, @options={:user=>"admin", :password=>"changeme", :oauth=>nil, :headers=>{:content_type=>"application/json", :accept=>"application/json;version=2"}}>, @config={:uri=>"http://192.168.122.114:3000/", :username=>"admin", :password=>"changeme"}>
irb(main):003:0> api.resource(:architectures).actions
=> [:index, :show, :create, :update, :destroy]
irb(main):004:0> api.resource(:architectures).call(:index)
=> [[{"architecture"=>{"name"=>"x86_64", "id"=>1, "created_at"=>"2013-10-17T20:42:08Z", "operatingsystem_ids"=>[], "updated_at"=>"2013-10-17T20:42:08Z"}}, {"architecture"=>{"name"=>"i386", "id"=>2, "created_at"=>"2013-10-17T20:42:08Z", "operatingsystem_ids"=>[], "updated_at"=>"2013-10-17T20:42:08Z"}}, {"architecture"=>{"name"=>"x86_63", "id"=>3, "created_at"=>"2013-10-18T10:07:23Z", "operatingsystem_ids"=>[], "updated_at"=>"2013-10-18T10:07:23Z"}}, {"architecture"=>{"name"=>"x86_62", "id"=>4, "created_at"=>"2013-10-18T10:08:06Z", "operatingsystem_ids"=>[], "updated_at"=>"2013-10-18T10:08:06Z"}}], "[{\"architecture\":{\"name\":\"x86_64\",\"id\":1,\"created_at\":\"2013-10-17T20:42:08Z\",\"operatingsystem_ids\":[],\"updated_at\":\"2013-10-17T20:42:08Z\"}},{\"architecture\":{\"name\":\"i386\",\"id\":2,\"created_at\":\"2013-10-17T20:42:08Z\",\"operatingsystem_ids\":[],\"updated_at\":\"2013-10-17T20:42:08Z\"}},{\"architecture\":{\"name\":\"x86_63\",\"id\":3,\"created_at\":\"2013-10-18T10:07:23Z\",\"operatingsystem_ids\":[],\"updated_at\":\"2013-10-18T10:07:23Z\"}},{\"architecture\":{\"name\":\"x86_62\",\"id\":4,\"created_at\":\"2013-10-18T10:08:06Z\",\"operatingsystem_ids\":[],\"updated_at\":\"2013-10-18T10:08:06Z\"}}]"]

```

Features
--------

#### Caching
The bindings cache the apidoc from the server. It has separated caches for each server it connects to. If the server sends apidoc hash in the headers ```Apipie-Apidoc-Hash: <md5>``` , the bindings can expire the cache and reload updated version before next request. If the server does not send the hashes, the cache does not expire and has to be deleted manually when necessary.

Sample patch for the server can be found here https://github.com/mbacovsky/foreman/commit/d35d76b9032bb3d3de2da7fb1dc780600eb08bdd

#### API introspection
It is possible to list available resources, actions and other params

```
irb(main):003:0> api.resource(:architectures).actions
=> [:index, :show, :create, :update, :destroy]

irb(main):004:0> api.resources
[
    [ 0] :roles,
    [ 1] :images,
    [ 2] :reports,
    ...
    [42] :host_classes
]
```



TODO
----
* parameter validation
* better configurability
* error handling
* logging
* lots of other things
