require 'simplecov'
SimpleCov.start do
  project_name 'ratistics'
  add_filter '/data/'
  add_filter '/spec/'
  add_filter '/tasks/'
end

require 'rspec'

require 'ratistics'

require 'hamster'

require 'active_record'
require 'standalone_migrations'

# import all the support files
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require File.expand_path(f) }

RSpec.configure do |config|

  config.before(:suite) do
    dbconfig = StandaloneMigrations::Configurator.load_configurations[:test]
  end

  config.before(:each) do
  end

  config.after(:each) do
  end

end
