#!/bin/bash --login

rvm use ruby-1.8.7-p371@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
bundle exec rspec spec

rvm use ruby-1.9.2-p320@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
bundle exec rspec spec

rvm use ruby-1.9.3-p327@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
bundle exec rspec spec

rvm use jruby-1.6.7@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
bundle exec rspec spec

rvm use jruby-1.6.7.2@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
bundle exec rspec spec

rvm use jruby-1.6.8@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
bundle exec rspec spec

rvm use jruby-1.7.0@ratistics --create
JRUBY_OPTS="-Xcext.enabled=true" gem install bundler &>/dev/null 
JRUBY_OPTS="-Xcext.enabled=true" bundle install &>/dev/null
bundle exec rspec spec

rvm use ree-1.8.7-2012.02@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
bundle exec rspec spec

