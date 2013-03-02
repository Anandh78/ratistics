$LOAD_PATH << File.expand_path("../lib", __FILE__)

require 'ratistics/version'
require 'date'
require 'rbconfig'

Gem::Specification.new do |s|
  s.name        = 'ratistics'
  s.version     = Ratistics::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Jerry D'Antonio"
  s.email       = 'jerry.dantonio@gmail.com'
  s.homepage    = 'https://github.com/jdantonio/ratistics/'
  s.summary     = "Ruby statistics functions"
  s.license     = 'MIT'
  s.date        = Date.today.to_s

  s.description = <<-EOF
    Ratistics is a purely functional library that provides basic statistics
    functions to Ruby programs. It is intended for small data sets only.

    This gem was designed for simplicity.
    Ratistics functions operate any any enumerable object and support block
    syntax for accessing complex data. This makes it possible to perform
    statistical computations on a wide range of collections, including
    ActiveRecord record sets.

    Ratistics is pronounced *ra-TIS-tics*. Just like "statistics" but with an 'R'
  EOF

  s.files            = Dir['README*', 'LICENSE*', 'CHANGELOG*']
  s.files           += Dir['{lib,spec}/**/*']
  s.test_files       = Dir['{spec}/**/*']
  s.extra_rdoc_files = ['README.md']
  s.extra_rdoc_files = Dir['README*', 'LICENSE*', 'CHANGELOG*']
  s.require_paths    = ['lib']

  s.required_ruby_version = '>= 1.8.7'
  s.post_install_message  = '"Lies, damned lies, and statistics"'

  # Production dependencies

  # Development dependencies

  s.add_development_dependency 'bundler'
    s.add_development_dependency 'rake'

  # test alternate collection classes
  s.add_development_dependency 'hamster'

    # test active_record collections
    s.add_development_dependency 'standalone_migrations'
    s.add_development_dependency 'activerecord', '~> 3.2.0'
    s.add_development_dependency 'sqlite3'

  unless RbConfig::CONFIG['ruby_install_name']=~ /^jruby$/i

    # create API documentation
    s.add_development_dependency 'yard'
    s.add_development_dependency 'redcarpet'
    #s.add_development_dependency 'github-markup'
  end

  # testing
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'countloc'

end
