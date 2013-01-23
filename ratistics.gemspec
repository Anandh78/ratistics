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
  s.description = %q{Ratistics provides basic statistical computation functions to Ruby programmers.}

  s.files         = Dir['Rakefile', 'README*', 'LICENSE*']
  s.files        += Dir['{lib,spec,tasks}/**/*']
  s.test_files    = Dir['{spec}/**/*']
  s.require_paths = ['lib']

  # Production dependencies

  # Development dependencies

  s.add_development_dependency 'hamster'
  
  s.add_development_dependency 'bundler'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'redcarpet'
  #s.add_development_dependency 'github-markup'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'

end
