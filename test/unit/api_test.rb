require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::API do

  let(:api) { ApipieBindings::API.new({:apidoc_cache_dir => 'test/unit/data', :apidoc_cache_name => 'dummy'}) }

  it "should provide resource" do
    result = api.resource(:users)
    result.must_be_kind_of ApipieBindings::Resource
  end

  it "should test if resource is available" do
    api.has_resource?(:users).must_equal true
  end

  it "should list resources" do
    api.resources.map(&:name).sort_by(&:to_s).must_equal [:comments, :posts, :users]
  end

  it "should call the method" do
    params = { :a => 1 }
    headers = { :content_type => 'application/json' }
    ApipieBindings::API.any_instance.expects(:http_call).with('get', '/users', params, headers, {})
    api.call(:users, :index, params, headers)
  end

  it "should call the method and skip param validation on demand" do
    params = { :user => { :vip => true } }
    headers = { :content_type => 'application/json' }
    options = { :skip_validation => true }
    ApipieBindings::API.any_instance.expects(:http_call).with('post', '/users', params, headers, options)
    api.call(:users, :create, params, headers, options)
  end

  it "should call the method and fill in the params" do
    params = { :id => 1 }
    headers = { :content_type => 'application/json' }
    ApipieBindings::API.any_instance.expects(:http_call).with('get', '/users/1', {}, headers, {})
    api.call(:users, :show, params, headers)
  end

  it "should return values from examples in dry_run mode" do
    api.dry_run = true
    result = api.call(:users, :index)
    result.must_be_kind_of Array
  end

  it "should allow to set dry_run mode in config params" do
    api = ApipieBindings::API.new({
      :apidoc_cache_dir => 'test/unit/data',
      :apidoc_cache_name => 'dummy',
      :dry_run => true })
    result = api.call(:users, :index)
    result.must_be_kind_of Array
  end

  it "should allow to set fake response in config params" do
    api = ApipieBindings::API.new({
      :apidoc_cache_dir => 'test/unit/data',
      :apidoc_cache_name => 'dummy',
      :dry_run => true,
      :fake_params => { [:users, :index] => {:default => [] } }} )
    result = api.call(:users, :index)
    result.must_be_kind_of Array
  end

  it "should preserve file in args (#2)" do
    api = ApipieBindings::API.new({
      :apidoc_cache_dir => 'test/unit/data',
      :apidoc_cache_name => 'dummy',
      :dry_run => true})
    s = StringIO.new; s << 'foo'
    headers = {:content_type => 'multipart/form-data', :multipart => true}
    RestClient::Response.expects(:create).with() {
      |body, head, args| args == [:post, {:file => s}, headers]
    }
    result = api.http_call(:post, '/api/path', {:file => s}, headers, {:response => :raw})
  end

  it "should process nil response safely" do
    api.send(:process_data, nil).must_equal ''
  end

  it "should process empty response safely" do
    api.send(:process_data, '').must_equal ''
  end

  it "should process empty JSON response safely" do
    api.send(:process_data, '{}').must_equal({})
  end

  it "should process JSON response safely" do
    api.send(:process_data, '{"a" : []}').must_equal({'a' => []})
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

    it "should load cache and its name from cache dir" do
      Dir["#{@dir}/*"].each { |f| File.delete(f) }
      FileUtils.cp('test/unit/data/dummy.json', File.join(@dir, 'api_cache.json'))
      api = ApipieBindings::API.new({:apidoc_cache_dir => @dir})
      api.apidoc_cache_name.must_equal 'api_cache'
    end
  end

  context "configuration" do
    it "should complain when no uri or cache dir is set" do
      proc {ApipieBindings::API.new({})}.must_raise ApipieBindings::ConfigurationError
    end

    it "should obey :apidoc_cache_base_dir to generate apidoc_cache_dir" do
      Dir.mktmpdir do |dir|
        api = ApipieBindings::API.new({:uri => 'http://example.com', :apidoc_cache_base_dir => dir, :api_version => 2})
        api.apidoc_cache_file.must_equal File.join(dir, 'http___example.com', 'v2', 'default.json')
      end
    end
  end

  context "redirects" do
    def configure_api_with(options={})
      default_options = {
        :apidoc_cache_dir => 'test/unit/data',
        :apidoc_cache_name => 'dummy'
      }
      ApipieBindings::API.new(default_options.merge(options))
    end

    it "should follow RestClient default behaviour by default" do
      api = configure_api_with()
      api.follow_redirects.must_equal :default
    end

    it "should be possible to change redirects handling" do
      api = configure_api_with(:follow_redirects => :never)
      api.follow_redirects.must_equal :never
    end

    context "follow_redirects = :never" do
      let(:api) { configure_api_with(:follow_redirects => :never) }
      let(:block) { api.send(:rest_client_call_block) }
      let(:response) { api.send(:create_fake_response, 301, "", "GET", "/", {}) }

      it "should rise error on redirect" do
        proc { block.call(response) }.must_raise RestClient::MovedPermanently
      end

      it "should rise error that contains the request" do
        err = proc { block.call(response) }.must_raise RestClient::MovedPermanently
        err.response.respond_to?(:request).must_equal true
      end
    end

    it "should follow redirect when follow_redirects = :always" do
      api = configure_api_with(:follow_redirects => :always)
      block = api.send(:rest_client_call_block)
      response = api.send(:create_fake_response, 301, "", "POST", "/", {})
      response.expects(:follow_redirection)
      block.call(response)
    end

    it "should use original handling when follow_redirects = :default" do
      api = configure_api_with(:follow_redirects => :default)
      block = api.send(:rest_client_call_block)
      response = api.send(:create_fake_response, 301, "", "GET", "/", {})
      response.expects(:return!)
      block.call(response)
    end
  end

  context "credentials" do

    let(:fake_empty_response) {
      data = ApipieBindings::Example.new('', '', '', 200, '[]')
      net_http_resp = Net::HTTPResponse.new(1.0, data.status, "")
      if RestClient::Response.method(:create).arity == 4 # RestClient >= 1.8.0
        RestClient::Response.create(data.response, net_http_resp, {},
          RestClient::Request.new(:method=>'GET', :url=>'http://example.com'))
      else
        RestClient::Response.create(data.response, net_http_resp, {})
      end
    }

    it "should call credentials to_param when :credentials are set and doing authenticated call" do
      Dir.mktmpdir do |dir|
        credentials = ApipieBindings::AbstractCredentials.new
        api = ApipieBindings::API.new({
          :uri => 'http://example.com', :apidoc_cache_base_dir => dir, :api_version => 2,
          :credentials => credentials})
        credentials.expects(:to_params).returns({:password => 'xxx'})
        api.stubs(:call_client).returns(fake_empty_response)

        api.http_call(:get, '/path')
      end
    end

    it "should not require credentials for loading apidoc when :apidoc_authenticated => false" do
      Dir.mktmpdir do |dir|
        api = ApipieBindings::API.new({
          :uri => 'http://example.com', :apidoc_cache_base_dir => dir, :api_version => 2,
          :apidoc_authenticated => false })
        api.expects(:unauthenticated_client)
        api.stubs(:call_client).returns(fake_empty_response)

        api.retrieve_apidoc
      end
    end

    it "should not require credentials for loading checksum when :apidoc_authenticated => false" do
      Dir.mktmpdir do |dir|
        api = ApipieBindings::API.new({
          :uri => 'http://example.com', :apidoc_cache_base_dir => dir, :api_version => 2,
          :apidoc_authenticated => false })
        api.expects(:unauthenticated_client)
        api.stubs(:call_client).returns(fake_empty_response)

        api.check_cache
      end
    end

    it "should clear credentials" do
      Dir.mktmpdir do |dir|
        credentials = ApipieBindings::AbstractCredentials.new
        api = ApipieBindings::API.new({
                                          :uri => 'http://example.com', :apidoc_cache_base_dir => dir, :api_version => 2,
                                          :credentials => credentials})
        credentials.expects(:clear)
        api.clear_credentials
      end
    end

    it "should call clear_credentials when doing authenticated call and auth error is raised" do
      Dir.mktmpdir do |dir|
        credentials = ApipieBindings::AbstractCredentials.new
        api = ApipieBindings::API.new({:uri => 'http://example.com', :apidoc_cache_base_dir => dir, :api_version => 2,
                                       :credentials => credentials})
        api.expects(:clear_credentials)
        api.stubs(:call_client).raises(RestClient::Unauthorized)
        assert_raises RestClient::Unauthorized do
          api.http_call(:get, '/path')
        end
      end
    end
  end

end
