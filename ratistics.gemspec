# -*- encoding: utf-8 -*-
$:.push File.join(File.dirname(__FILE__), 'lib')

require 'ratistics/version'

Gem::Specification.new do |s|
  s.name        = 'ratistics'
  s.version     = Ratistics::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jerry D'Antonio"]
  s.email       = ['jerry.dantonio@gmail.com']
  s.homepage    = 'https://github.com/jdantonio/ratistics/'
  s.summary     = %q{Ruby statistics functions.}
  s.description = %q{Ratistics provides basic statistics computations and functions to Ruby programmers.}

  s.files         = Dir['README*', 'LICENSE*']
  s.files        += Dir['{lib,spec}/**/*']
  s.test_files    = Dir['{spec}/**/*']
  s.require_paths = ['lib']

  s.post_install_message = 'Happy computing!'

  # Production dependencies

  # Development dependencies
 
  s.add_development_dependency 'bundler'

  # test alternate collection classes
  s.add_development_dependency 'hamster'

  # test active_record collections
  s.add_dependency 'standalone_migrations'
  s.add_dependency 'activerecord', '~> 3.2.0'
  s.add_dependency 'sqlite3'

  # create API documentation
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'redcarpet'
  #s.add_development_dependency 'github-markup'

  # testing
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'

end
