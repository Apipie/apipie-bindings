require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::Example do

  it "should parse the example format from apidoc POST" do
    example_string = "POST /api/architectures\n{\n  \"architecture\": {\n    \"name\": \"i386\"\n  }\n}\n200\n{\n  \"architecture\": {\n    \"name\": \"i386\",\n    \"id\": 501905020,\n    \"updated_at\": \"2012-12-18T15:24:43Z\",\n    \"operatingsystem_ids\": [],\n    \"created_at\": \"2012-12-18T15:24:43Z\"\n  }\n}"
    ex = ApipieBindings::Example.parse(example_string)
    ex.http_method.must_equal 'POST'
    ex.path.must_equal '/api/architectures'
    ex.args.must_equal "{\n  \"architecture\": {\n    \"name\": \"i386\"\n  }\n}"
    ex.status.must_equal 200
    ex.response.must_include "{\n  \"architecture\": "
  end

  it "should parse the example format from apidoc GET" do
    example_string = "GET /api/architectures/x86_64\n200\n{\n  \"architecture\": {\n    \"name\": \"x86_64\",\n    \"id\": 501905019,\n    \"updated_at\": \"2012-12-18T15:24:42Z\",\n    \"operatingsystem_ids\": [\n      309172073,\n      1073012828,\n      331303656\n    ],\n    \"created_at\": \"2012-12-18T15:24:42Z\"\n  }\n}"
    ex = ApipieBindings::Example.parse(example_string)
    ex.http_method.must_equal 'GET'
    ex.path.must_equal '/api/architectures/x86_64'
    ex.args.must_equal ""
    ex.status.must_equal 200
    ex.response.must_include "{\n  \"architecture\": "
  end

end
