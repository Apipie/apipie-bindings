require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::API do

  let(:api) { ApipieBindings::API.new({:uri => 'https://localhost', :username => 'admin', :password => 'admin',
                :apidoc_cache_file => 'test/unit/data/architecture.json'}) }

  it "should provide resource" do
    result = api.resource(:architectures)
    result.must_be_kind_of ApipieBindings::Resource
  end

  it "should test if resource is available" do
    api.has_resource?(:architectures).must_equal true
  end

  it "should list resources" do
    api.resources.must_equal [:architectures]
  end

  # it "should have apidoc_cache_file available" do
  # end

  it "should call the method" do
    params = { :a => 1 }
    headers = { :content_type => 'application/json' }
    ApipieBindings::API.any_instance.expects(:http_call).with('get', '/api/architectures', params, headers)
    api.call(:architectures, :index, params, headers)
  end

  it "should call the method and fill in the params" do
    params = { :id => 1 }
    headers = { :content_type => 'application/json' }
    ApipieBindings::API.any_instance.expects(:http_call).with('get', '/api/architectures/1', {}, headers)
    api.call(:architectures, :show, params, headers)
  end

end
