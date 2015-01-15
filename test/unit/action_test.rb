require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::Action do

  let(:resource) { ApipieBindings::API.new({:apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'dummy'}).resource(:users) }

  it "should allow user to call the action" do
    params = { :a => 1 }
    headers = { :content_type => 'application/json' }
    ApipieBindings::API.any_instance.expects(:call).with(:users, :index, params, headers, {})
    resource.action(:index).call(params, headers)
  end

  it "should return routes" do
    resource.action(:index).routes.first.must_be_kind_of ApipieBindings::Route
  end

  it "should find suitable route" do
    resource.action(:index).find_route.path.must_equal "/users"
  end

  it "should return params" do
    resource.action(:create).params.map(&:name).must_equal ['user']
  end

  # TODO add tests for more find_route cases
    # @param possible_apis [Array] Array of hasahs in form of
    #   [{:api_url => '/path1', :http_method => 'GET'}, {...}]
    # @param params [Hash] enterred params
    # @return api that suits the enterred params mosts
    #
    # Given this paths:
    #   1. +/comments+
    #   2. +/users/:user_id/comments+
    #   3. +/users/:user_id/posts/:post_id/comments+
    #
    # If +:user_id+ and +:post_id+ is pecified, the third path is
    # used. If only +:user_id+ is specified, the second one is used.
    # The selection defaults to the path with the least number of
    # incuded params in alphanumeric order.


  it "should validate incorrect params" do
    e = proc do
      resource.action(:create).validate!({ :user => { :foo => "foo" } })
    end.must_raise(ApipieBindings::MissingArgumentsError)
    e.message.must_match /: name$/

    e = proc do
      # completely different sub-hash; should still fail
      resource.action(:create).validate!({ :apple => { :foo => "foo" } })
    end.must_raise(ApipieBindings::MissingArgumentsError)
    e.message.must_match /: name$/
  end

  it "should accept correct params" do
    resource.action(:create).validate!({:user => { :name => 'John Doe' } })
    resource.action(:create_unnested).validate!(:name => "John Doe")
  end

  it "should have name visible in puts" do
    out, err = capture_io { puts resource.action(:index) }
    out.must_equal "<Action :index>\n"
  end

  it "should have name visible in inspect" do
    resource.action(:index).inspect.must_equal "<Action :index>"
  end

  it "should have examples" do
    resource.action(:index).examples.length.must_equal 1
  end

end
