require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::Route do

  let(:route) { ApipieBindings::Route.new("/api/architectures/:id", "GET") }
  it "should list params in path" do
    route.params_in_path.must_equal ['id']
  end

  it "should downcase the method" do
    route.method.must_equal 'get'
  end

  it "should fill in the params" do
    route.path({ "id" => 1 }).must_equal "/api/architectures/1"
  end

  it "should fill in the params as symbols" do
    route.path({ :id => 1 }).must_equal "/api/architectures/1"
  end

  it "should return the path as is without the params" do
    route.path.must_equal "/api/architectures/:id"
  end

  it "should have path visible in puts" do
    out, _err = capture_io { puts route }
    out.must_equal "<Route /api/architectures/:id>\n"
  end

  it "should have path visible in inspect" do
    route.inspect.must_equal "<Route /api/architectures/:id>"
  end


end
