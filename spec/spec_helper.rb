require 'simplecov'
SimpleCov.start do
  project_name 'ratistics'
  add_filter '/data/'
  add_filter '/spec/'
  add_filter '/tasks/'
end

jruby = (0 == (RbConfig::CONFIG['ruby_install_name']=~ /^jruby$/i))

require 'ratistics'

require 'rspec'
require 'hamster'
require 'active_record' unless jruby

# import all the support files
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require File.expand_path(f) }

RSpec.configure do |config|

  config.before(:suite) do
  end

  config.before(:each) do
  end

  config.after(:each) do
  end

end
