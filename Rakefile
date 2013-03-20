$:.push File.join(File.dirname(__FILE__), 'lib')
$:.push File.join(File.dirname(__FILE__), 'tasks/support')

require 'rubygems'
require 'bundler/gem_tasks'
require 'rspec'
require 'rspec/core/rake_task'
require 'rbconfig'

require 'ratistics'

jruby = (0 == (RbConfig::CONFIG['ruby_install_name']=~ /^jruby$/i))
windows = (RbConfig::CONFIG['host_os'] =~ /mswin32/i || RbConfig::CONFIG['host_os'] =~ /mingw32/i)
ar = !(jruby || windows)

Bundler::GemHelper.install_tasks

if jruby
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--color --tag ~@ar'
  end
elsif windows
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '-fd --color --tag ~@ar --tag ~@hamster'
  end
else
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--color'
  end
end

if ar
  require 'standalone_migrations'
  StandaloneMigrations::Tasks.load_tasks

  require 'yard'
  YARD::Rake::YardocTask.new do |t|
  end
end

$:.unshift 'tasks'
Dir.glob('tasks/**/*.rake').each do|rakefile|
  load rakefile
end

task :default => [:spec]
#task :default do
#puts `make`
#fail if $? != 0
#end
