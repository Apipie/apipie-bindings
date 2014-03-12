require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::IndifferentHash do

  let(:hash) { ApipieBindings::IndifferentHash.new({
    "one" => 1,
    :two => 2,
    :nested => { "one" => 1, :two => 2},
    :nested_array => [[{"one" => 1}]] })}

  it "should allow access with symbol" do
    hash[:one].must_equal 1
  end

  it "should allow access with string" do
    hash['two'].must_equal 2
  end

  it "should allow access nested with symbol" do
    hash['nested'][:one].must_equal 1
  end

  it "should allow access nested in array with symbol" do
    hash['nested_array'][0][0][:one].must_equal 1
  end


end
