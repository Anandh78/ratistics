#!/bin/bash --login

rvm use ruby-2.0.0-p0@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
rake spec

rvm use ruby-1.9.3@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
rake spec

rvm use ruby-1.9.2@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
rake spec

rvm use ruby-1.8.7@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
rake spec

rvm use ree-1.8.7@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
rake spec

rvm use rbx-head-d19@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
rake spec

rvm use rbx-head-d18@ratistics --create
gem install bundler &>/dev/null 
bundle install &>/dev/null
rake spec

rvm use jruby-1.7.0@ratistics --create
JRUBY_OPTS="-Xcext.enabled=true" gem install bundler &>/dev/null 
JRUBY_OPTS="-Xcext.enabled=true" bundle install &>/dev/null
JRUBY_OPTS="-Xcext.enabled=true" rake spec

rvm use jruby-1.6.8@ratistics --create
JRUBY_OPTS="-Xcext.enabled=true" gem install bundler &>/dev/null 
JRUBY_OPTS="-Xcext.enabled=true" bundle install &>/dev/null
JRUBY_OPTS="-Xcext.enabled=true" rake spec

rvm use jruby-1.6.7.2@ratistics --create
JRUBY_OPTS="-Xcext.enabled=true" gem install bundler &>/dev/null 
JRUBY_OPTS="-Xcext.enabled=true" bundle install &>/dev/null
JRUBY_OPTS="-Xcext.enabled=true" rake spec

rvm use jruby-1.6.7@ratistics --create
JRUBY_OPTS="-Xcext.enabled=true" gem install bundler &>/dev/null 
JRUBY_OPTS="-Xcext.enabled=true" bundle install &>/dev/null
JRUBY_OPTS="-Xcext.enabled=true" rake spec

cd .
bundle update
