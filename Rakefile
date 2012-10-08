# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "test_guard"
  gem.homepage = "http://github.com/chetan/test_guard"
  gem.license = "MIT"
  gem.summary = %Q{simple test script using guard}
  gem.description = %Q{simple test script using guard}
  gem.email = "chetan@pixelcop.net"
  gem.authors = ["Chetan Sarva"]
  gem.executables = "test_guard"
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new
