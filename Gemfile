source "http://rubygems.org"

gemspec

if RUBY_VERSION < "1.9"
gem 'rest-client', '< 1.7'
gem 'mime-types', '~> 1.0'
end

# load local gemfile
local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
self.instance_eval(Bundler.read_file(local_gemfile)) if File.exist?(local_gemfile)
