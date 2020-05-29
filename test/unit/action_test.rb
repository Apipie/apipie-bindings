require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::Action do

  let(:dummy_api) { ApipieBindings::API.new({:apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'dummy'}) }
  let(:resource) { dummy_api.resource(:users)}

  it "should allow user to call the action" do
    params = { :a => 1 }
    headers = { :content_type => 'application/json' }
    ApipieBindings::API.any_instance.expects(:call).with(:users, :index, params, headers, {})
    resource.action(:index).call(params, headers)
  end

  it "should return routes" do
    resource.action(:index).routes.first.must_be_kind_of ApipieBindings::Route
  end

  describe "#find_route" do
    let(:archive_action) { dummy_api.resource(:comments).action(:archive) }

    it "should find suitable route" do
      resource.action(:index).find_route.path.must_equal "/users"
    end

    it "should find longest matching route" do
      archive_action.find_route(:id => 1, :user_id => 1).path.must_equal "/archive/users/:user_id/comments/:id"
    end

    it "should find longest matching route ignoring nil params in the path" do
      archive_action.find_route(:id => 1, :user_id => nil).path.must_equal "/archive/comments/:id"
    end

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


  describe "validate!" do
    it "should raise on missing required params" do
      e = proc do
        resource.action(:create).validate!({ :user => { :vip => true } })
      end.must_raise(ApipieBindings::MissingArgumentsError)
      e.message.must_match(/: user\[name\]$/)
    end

    it "should raise on missing nested required params (hash)" do
      e = proc do
        resource.action(:create).validate!({
          :user => {
            :name => 'Jogn Doe',
            :address => {
              :street => 'K JZD'
            }
          }
        })
      end.must_raise(ApipieBindings::MissingArgumentsError)
      e.message.must_match(/: user\[address\]\[city\]$/)
    end

    it "should raise on missing nested required params (array)" do
      e = proc do
        resource.action(:create).validate!({
          :user => {
            :name => 'Jogn Doe',
            :contacts => [
             {:kind => 'email'},
            ]
          }
        })
      end.must_raise(ApipieBindings::MissingArgumentsError)
      e.message.must_match(/: user\[contacts\]\[0\]\[contact\]$/)
    end

    it "should raise on invalid param format" do
      e = proc do
        resource.action(:create).validate!({
          :user => {
            :name => 'Jogn Doe',
            :contacts => [
             1,
             2
            ]
          }
        })
      end.must_raise(ApipieBindings::InvalidArgumentTypesError)
      e.message.must_match(/user\[contacts\]\[0\] - Hash was expected/)
      e.message.must_match(/user\[contacts\]\[1\] - Hash was expected/)
    end

    it "should accept minimal correct params" do
      resource.action(:create).validate!({:user => { :name => 'John Doe' } })
      resource.action(:create_unnested).validate!(:name => "John Doe")
    end

    it "should accept full correct params" do
      resource.action(:create).validate!({
        :user => {
          :name => 'John Doe',
          :vip => true,
          :address => {
            :city => 'Ankh-Morpork',
            :street => 'Audit Alley'
          },
          :contacts => [
            {:contact => 'john@doe.org', :kind => 'email'},
            {:contact => '123456', :kind => 'pobox'}
          ]
        }
      })
    end
  end

  it "should have name visible in puts" do
    out, _err = capture_io { puts resource.action(:index) }
    out.must_equal "<Action users:index>\n"
  end

  it "should have name visible in inspect" do
    resource.action(:index).inspect.must_equal "<Action users:index>"
  end

  it "should have examples" do
    resource.action(:index).examples.length.must_equal 1
  end

end
