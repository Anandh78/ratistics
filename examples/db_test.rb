require 'rubygems'
require 'active_record'
require 'sqlite3'
require 'pp'

$:.push File.join(File.dirname(__FILE__), '../lib')
$:.push File.join(File.dirname(__FILE__), '../spec')

require 'ratistics'
require 'support/db'

dbconfig = {:adapter=>'sqlite3', :database=>File.join(File.dirname(__FILE__), '../db/development.sqlite3')}
ActiveRecord::Base.establish_connection(dbconfig)

p Ratistics.mean(Ratistics::Racer.all){|racer| racer.age }
puts
p Ratistics.median(Ratistics::Racer.all){|racer| racer.age }
puts
p Ratistics.mode(Ratistics::Racer.all){|racer| racer.age }
puts
p Ratistics.frequency(Ratistics::Racer.all){|racer| racer.age }
puts
p Ratistics.probability(Ratistics::Racer.all){|racer| racer.age }
puts
