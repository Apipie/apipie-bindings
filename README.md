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

TODO
----
* smarter caching
* parameter validation
* better configurability
* error handling
* logging
* lots of other things
