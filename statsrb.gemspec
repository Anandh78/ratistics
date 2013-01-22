# -*- encoding: utf-8 -*-
$:.push File.join(File.dirname(__FILE__), 'lib')

require 'statsrb/version'

Gem::Specification.new do |s|
  s.name        = 'statsrb'
  s.version     = Statsrb::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jerry D'Antonio"]
  s.email       = ['jerry.dantonio@gmail.com']
  s.homepage    = 'https://github.com/jdantonio/statsrb/'
  s.summary     = %q{Ruby stats helpers.}
  s.description = %q{Ruby stats helpers.}

  s.files         = Dir['Rakefile', 'README*', 'LICENSE*']
  s.files        += Dir['{bin,features,lib,man,spec,tasks}/**/*']
  s.test_files    = Dir['{spec,features}/**/*']
  s.bindir        = 'bin'
  s.executables   = Dir.glob('bin/*').map { |f| File.basename(f) }
  s.require_paths = ['lib', 'lib/statsrb']

  s.default_executable = 'statsrb'

  # Production dependencies

  s.add_dependency 'activesupport', '~> 3.2.0'
  s.add_dependency 'thor'

  s.add_dependency 'gem-man'
  s.add_dependency 'ronn'

  # Development dependencies
  
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'geminabox'

  s.add_development_dependency 'hamster'

  s.add_development_dependency 'debugger'
  s.add_development_dependency 'rake'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'

  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'

end
