require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::Action do

  let(:resource) { ApipieBindings::API.new({:uri => 'https://localhost', :username => 'admin', :password => 'admin',
                :apidoc_cache_file => 'test/unit/data/architecture.json'}).resource(:architectures) }

  it "should allow user to call the action" do
    params = { :a => 1 }
    headers = { :content_type => 'application/json' }
    ApipieBindings::API.any_instance.expects(:call).with(:architectures, :index, params, headers)
    resource.action(:index).call(params, headers)
  end

  it "should return routes" do
    resource.action(:index).routes.first.must_be_kind_of ApipieBindings::Route
  end

  it "should find suitable route" do
    resource.action(:index).find_route.path.must_equal "/api/architectures"
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


  it "should validate the params" do
    resource.action(:create).validate!({ :architecture => { :name => 'i386' } })
  end

end
