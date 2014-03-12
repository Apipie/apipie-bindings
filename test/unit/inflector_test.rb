require File.join(File.dirname(__FILE__), 'test_helper')

describe ApipieBindings::Inflector do

  it "should pluralize 'word'" do
    ApipieBindings::Inflector.pluralize('word').must_equal 'words'
  end

  it "should singularize 'words'" do
    ApipieBindings::Inflector.singularize('words').must_equal 'word'
  end

  it "should pluralize 'gpg_key'" do
    ApipieBindings::Inflector.pluralize('gpg_key').must_equal 'gpg_keys'
  end

end
