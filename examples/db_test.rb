require 'rubygems'
require 'active_record'
require 'sqlite3'
require 'pp'

$:.push File.join(File.dirname(__FILE__), '../lib')

require 'ratistics'

class Racer < ActiveRecord::Base
end

dbconfig = {:adapter=>'sqlite3', :database=>File.join(File.dirname(__FILE__), '../db/development.sqlite3')}
ActiveRecord::Base.establish_connection(dbconfig)

p Ratistics.mean(Racer.all){|racer| racer.age }
puts
p Ratistics.median(Racer.all){|racer| racer.age }
puts
p Ratistics.mode(Racer.all){|racer| racer.age }
puts
p Ratistics.frequency(Racer.all){|racer| racer.age }
puts
p Ratistics.probability(Racer.all){|racer| racer.age }
puts
