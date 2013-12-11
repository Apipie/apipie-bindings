require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::Resource do

  let(:resource) { ApipieBindings::API.new({:apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'architecture'}).resource(:architectures) }

  it "should list actions" do
    resource.actions.must_equal [:index, :show, :create]
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

end
