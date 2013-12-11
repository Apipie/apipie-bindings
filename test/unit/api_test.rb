require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::API do

  let(:api) { ApipieBindings::API.new({:apidoc_cache_dir => 'test/unit/data', :apidoc_cache_name => 'architecture'}) }

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
    ApipieBindings::API.any_instance.expects(:http_call).with('get', '/api/architectures', params, headers, {})
    api.call(:architectures, :index, params, headers)
  end

  it "should call the method and fill in the params" do
    params = { :id => 1 }
    headers = { :content_type => 'application/json' }
    ApipieBindings::API.any_instance.expects(:http_call).with('get', '/api/architectures/1', {}, headers, {})
    api.call(:architectures, :show, params, headers)
  end

  context "update_cache" do

    before :each do
      @dir = Dir.mktmpdir
      @api = ApipieBindings::API.new({:apidoc_cache_dir => @dir, :apidoc_cache_name => 'cache'})
      @api.stubs(:retrieve_apidoc).returns(nil)
      File.open(@api.apidoc_cache_file, "w") { |f| f.write(['test'].to_json) }
    end

    after :each do
      Dir["#{@dir}/*"].each { |f| File.delete(f) }
      Dir.delete(@dir)
    end

    it "should clean the internal cache when the name has changed" do
      @api.update_cache('new_name')
      @api.apidoc.must_equal nil
    end

    it "should clean the cache dir when the name has changed" do
      @api.update_cache('new_name')
      Dir["#{@dir}/*"].must_be_empty
    end

    it "should set the new cache name when the name has changed" do
      @api.update_cache('new_name')
      @api.apidoc_cache_file.must_equal File.join(@dir, 'new_name.json')
    end

    it "should not touch enything if the name is same" do
      @api.update_cache('cache')
      @api.apidoc.must_equal ['test']
    end

    # caching is turned off on server
    it "should not touch enything if the name is nil" do
      @api.update_cache(nil)
      @api.apidoc.must_equal ['test']
    end
  end

end
