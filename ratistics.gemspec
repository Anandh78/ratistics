# -*- encoding: utf-8 -*-
$:.push File.join(File.dirname(__FILE__), 'lib')

require 'ratistics/version'

Gem::Specification.new do |s|
  s.name        = 'ratistics'
  s.version     = Ratistics::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Jerry D'Antonio"
  s.email       = 'jerry.dantonio@gmail.com'
  s.homepage    = 'https://github.com/jdantonio/ratistics/'
  s.summary     = "Ruby statistics functions"
  s.license     = 'MIT'

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

  # test alternate collection classes
  s.add_development_dependency 'hamster'

  # test active_record collections
  s.add_development_dependency 'standalone_migrations'
  s.add_development_dependency 'activerecord', '~> 3.2.0'
  s.add_development_dependency 'sqlite3'

  # create API documentation
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'redcarpet'
  #s.add_development_dependency 'github-markup'

  # testing
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'

end
