require 'active_record'

$:.push File.join(File.dirname(__FILE__), '../lib')

require 'ratistics'

########################
### Database Classes

class Racer < ActiveRecord::Base
end

class Pregnancy < ActiveRecord::Base
  belongs_to :female_respondent,
    :primary_key => :caseid,
    :foreign_key => :caseid
end

class FemaleRespondent < ActiveRecord::Base
  has_many :pregnancy,
    :primary_key => :caseid,
    :foreign_key => :caseid
end

########################
### Dump old data

puts 'Deleting old data...'
Racer.delete_all
FemaleRespondent.delete_all
Pregnancy.delete_all

########################
### Racer

racer_definition = [
  {:field => :place, :start => 1, :end => 6, :cast => :to_i},
  {:field => :div_tot, :start =>  7, :end => 15},
  {:field => :div, :start =>  16, :end => 21},
  {:field => :guntime, :start =>  22, :end => 29},
  {:field => :nettime, :start =>  30, :end => 38},
  {:field => :pace, :start =>  39, :end => 44},
  {:field => :name, :start =>  45, :end => 67},
  {:field => :age, :start =>  68, :end => 70, :cast => :to_i},
  {:field => :gender, :start =>  71, :end => 72},
  {:field => :race_num, :start =>  73, :end => 78, :cast => :to_i},
  {:field => :city_state, :start =>  79, :end => 101},
]

puts 'Loading racer data...'
racer_file = File.join(File.dirname(__FILE__), '../examples/race.dat.gz')
racer = Ratistics::Load.dat_gz_file(racer_file, racer_definition)

puts 'Seeding racer data...'
racer.each do |record|
  Racer.create(record)
end

puts "Seeded #{Racer.all.count} racer records."
pp Racer.first 
puts

########################
### FemaleRespondent

respondent_definition = [
  {:field => :caseid, :start => 1, :end => 12, :cast => :to_i}
]

puts 'Loading female respondent data...'
respondent_file = File.join(File.dirname(__FILE__), '../examples/2002FemResp.dat.gz')
respondents = Ratistics::Load.dat_gz_file(respondent_file, respondent_definition)

puts 'Seeding female respondent data...'
respondents.each do |record|
  FemaleRespondent.create(record)
end

puts "Seeded #{FemaleRespondent.all.count} records."
#pp FemaleRespondent.first
puts

########################
### Pregnancy

pregnancy_definition = [
  {:field => :caseid, :start => 1, :end => 12, :cast => :to_i},
  {:field => :nbrnaliv, :start => 22, :end => 22, :cast => :to_i},
  {:field => :babysex, :start => 56, :end => 56, :cast => :to_i},
  {:field => :birthwgt_lb, :start => 57, :end => 58, :cast => :to_i},
  {:field => :birthwgt_oz, :start => 59, :end => 60, :cast => :to_i},
  {:field => :prglength, :start => 275, :end => 276, :cast => :to_i},
  {:field => :outcome, :start => 277, :end => 277, :cast => :to_i},
  {:field => :birthord, :start => 278, :end => 279, :cast => :to_i},
  {:field => :agepreg, :start => 284, :end => 287, :cast => :to_i},
  {:field => :finalwgt, :start => 423, :end => 440, :cast => :to_f},
]

puts 'Loading pregnancy data...'
pregnancy_file = File.join(File.dirname(__FILE__), '../examples/2002FemPreg.dat.gz')
pregnancies = Ratistics::Load.dat_gz_file(pregnancy_file, pregnancy_definition)

puts 'Seeding pregnancy data...'
pregnancies.each do |record|
  Pregnancy.create(record)
end

puts "Seeded #{Pregnancy.all.count} records."
#pp Pregnancy.first
puts
