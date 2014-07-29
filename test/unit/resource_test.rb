require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::Resource do

  let(:resource) { ApipieBindings::API.new({:apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'architecture'}).resource(:architectures) }

  it "should list actions" do
    resource.actions.map(&:name).must_equal [:index, :show, :create, :create_unnested]
  end

  it "should test action existence" do
    resource.has_action?(:index).must_equal true
  end

  it "should return action" do
    resource.action(:index).must_be_kind_of ApipieBindings::Action
  end

  it "should allow user to call the action" do
    params = { :a => 1 }
    headers = { :content_type => 'application/json' }
    ApipieBindings::API.any_instance.expects(:call).with(:architectures, :index, params, headers, {})
    resource.call(:index, params, headers)
  end

  it "should allow user to call the action with minimal params" do
    ApipieBindings::API.any_instance.expects(:call).with(:architectures, :index, {}, {}, {})
    resource.call(:index)
  end

  it "should print name in singular on demand" do
    resource.singular_name.must_equal 'architecture'
  end

  it "should have name visible in puts" do
    out, err = capture_io { puts resource }
    out.must_equal "<Resource :architectures>\n"
  end

  it "should have name visible in inspect" do
    resource.inspect.must_equal "<Resource :architectures>"
  end

  it "should rise error when the resource does no exist" do
    assert_raises( NameError ){ ApipieBindings::API.new({:apidoc_cache_dir => 'test/unit/data',
      :apidoc_cache_name => 'architecture'}).resource(:none) }
  end
end
