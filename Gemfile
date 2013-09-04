source "http://rubygems.org"

gem "turn"
gem "awesome_print"
gem "listen"
gem "growl"
gem "simplecov",          :platform => [:mri_19, :mri_20]
gem "simplecov-console",  :platform => [:mri_19, :mri_20]
gem "single_test"

group :development do
  gem "bundler"
  gem 'jeweler', :git => "https://github.com/chetan/jeweler.git", :branch => "bixby"

  # not supported by jruby
  gem "debugger",     :platforms => [:mri_19, :mri_20]
  gem "debugger-pry", :platforms => [:mri_19, :mri_20], :require => "debugger/pry"

  # platform specific deps
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
end
