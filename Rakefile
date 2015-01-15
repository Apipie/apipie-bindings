require 'rake/testtask'
require 'bundler/gem_tasks'
require 'ci/reporter/rake/minitest'

task :default => :test

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = Dir.glob('test/**/*_test.rb')
  t.verbose = true
end

def inside_dummy_app(&block)
  original_gemfile = ENV['BUNDLE_GEMFILE']
  ENV['BUNDLE_GEMFILE'] = './Gemfile'
  Dir.chdir('test/dummy', &block)
ensure
  ENV['BUNDLE_GEMFILE'] = original_gemfile
end

file 'test/unit/data/dummy.json' do
  inside_dummy_app do
    if system('bundle install') && system('bundle exec rake apipie:cache')
      FileUtils.copy('public/apipie-cache/apipie.json', '../unit/data/dummy.json')
    else
      fail 'Something went wrong when generating the cache files'
    end
  end
end

task :test => "test/unit/data/dummy.json"
