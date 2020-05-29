require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::Param do

  let(:param) {ApipieBindings::Param.new({
          "allow_nil" => false,
          "description" => "<p>Architecture</p>",
          "expected_type" => "hash",
          "full_name" => "architecture",
          "name" => "architecture",
          "params" => [
              {
                  "allow_nil" => false,
                  "description" => "",
                  "expected_type" => "string",
                  "full_name" => "architecture[name]",
                  "name" => "name",
                  "required" => false,
                  "validator" => "Must be String"
              }

          ],
          "required" => true,
          "validator" => "Must be a Hash"
      }
    )}
  it "should create nested params" do
    param.params.first.name.must_equal 'name'
  end

  it "should have expected_type" do
    param.expected_type.must_equal :hash
  end

  it "should have description that strip html tags" do
    param.description.must_equal "Architecture"
  end

  it "should have required?" do
    param.required?.must_equal true
    param.params.first.required?.must_equal false
  end

  it "should have validator" do
    param.validator.must_equal "Must be a Hash"
  end

  it "should have full name, type and required visible in puts" do
    out, _err = capture_io { puts param }
    out.must_equal "<Param *architecture (Hash)>\n"
  end

  it "should have full name, type and required visible in inspect" do
    param.inspect.must_equal "<Param *architecture (Hash)>"
  end

end
