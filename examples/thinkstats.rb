# Answers to the exercises in the book Think Stats
# at http://greenteapress.com/thinkstats/
#
# Answers were checked against the author's code and the
# online statistics calculators at
# http://www.alcula.com/calculators/statistics/mean/

require 'rubygems'
require 'ratistics'
require 'ratistics/monkey'
#require 'hamster'
#require 'pp'

FEMRESP = File.expand_path(File.join(File.dirname(__FILE__), '2002FemResp.dat.gz'))
FEMPREG = File.expand_path(File.join(File.dirname(__FILE__), '2002FemPreg.dat.gz'))

FEMRESP_FIELDS = [
  {:field => :caseid, :start => 1, :end => 12, :cast => :to_i},
]

FEMPREG_FIELDS = [
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

def ex_1_3_p1
  pregnancies = Ratistics::Load.dat_gz_file(FEMPREG, FEMPREG_FIELDS)
  puts "Number of pregnancies #{pregnancies.count}"
  return nil
end

def ex_1_3_p2
  pregnancies = Ratistics::Load.dat_gz_file(FEMPREG, FEMPREG_FIELDS)
  live = pregnancies.select{|record| record[:outcome] == 1 }

  puts "Number of live births #{live.count}"
  return nil
end

def ex_1_3_p3
  pregnancies = Ratistics::Load.dat_gz_file(FEMPREG, FEMPREG_FIELDS)
  first = pregnancies.select{|record| record[:outcome] == 1 && record[:birthord] == 1 }
  other = pregnancies.select{|record| record[:outcome] == 1 && record[:birthord] > 1 }

  puts "Number of first-borns #{first.count}"
  puts "Number of other #{other.count}"
  return nil
end

def ex_1_3_p4
  pregnancies = Ratistics::Load.dat_gz_file(FEMPREG, FEMPREG_FIELDS)
  first = pregnancies.select{|record| record[:outcome] == 1 && record[:birthord] == 1 }
  other = pregnancies.select{|record| record[:outcome] == 1 && record[:birthord] > 1 }

  first_prglength_mean = Ratistics.mean(first){|record| record[:prglength] }
  other_prglength_mean = Ratistics.mean(other){|record| record[:prglength] }

  puts "Average length of pregnancy for first-borns #{first_prglength_mean}"
  puts "Average length of pregnancy for others #{other_prglength_mean}"

  delta = 7* Ratistics.delta(first_prglength_mean, other_prglength_mean)
  puts "The difference between the averages is #{delta} days"
  return nil
end

def ex_2_1
  pumpkins = [1, 1, 1, 3, 3, 591]

  puts "Pumpkin mean is #{Ratistics.mean(pumpkins)}"
  puts "Pumpkin variance is #{Ratistics.variance(pumpkins)}"
  puts "Pumpkin standard deviation is #{Ratistics.standard_deviation(pumpkins)}"
  return nil
end

def ex_2_2
  pregnancies = Ratistics::Load.dat_gz_file(FEMPREG, FEMPREG_FIELDS)
  first = pregnancies.select{|record| record[:outcome] == 1 && record[:birthord] == 1 }
  other = pregnancies.select{|record| record[:outcome] == 1 && record[:birthord] > 1 }

  first_prglength_mean = Ratistics.mean(first){|record| record[:prglength] }
  other_prglength_mean = Ratistics.mean(other){|record| record[:prglength] }

  variance = Ratistics.variance([first_prglength_mean, other_prglength_mean])
  standard_deviation = Ratistics.standard_deviation([first_prglength_mean, other_prglength_mean])

  puts "Variance of gestation times for first-borns and others is #{variance}"
  puts "Standard deviation of gestation times for first-borns and others is #{standard_deviation}"
  return nil
end

def ex_2_3
  pregnancies = Ratistics::Load.dat_gz_file(FEMPREG, FEMPREG_FIELDS)
  first = pregnancies.select{|record| record[:outcome] == 1 && record[:birthord] == 1 }
  other = pregnancies.select{|record| record[:outcome] == 1 && record[:birthord] > 1 }

  first_prglength_mode = Ratistics.mode(first){|record| record[:prglength] }
  other_prglength_mode = Ratistics.mode(other){|record| record[:prglength] }

  first_prglength_frequency = Ratistics.frequency(first){|record| record[:prglength] }
  other_prglength_frequency = Ratistics.frequency(other){|record| record[:prglength] }

  puts "The modes of gestation for first-borns is #{first_prglength_mode}"
  puts "The modes of gestation for others is #{other_prglength_mode}"

  first_prglength_frequency = first_prglength_frequency.keys.sort.reduce([]) {|memo, key|
    memo << [key, first_prglength_frequency[key]]
  }
  other_prglength_frequency = other_prglength_frequency.keys.sort.reduce([]) {|memo, key|
    memo << [key, other_prglength_frequency[key]]
  }

  puts "The frequency of gestation for first-borns is:"
  p first_prglength_frequency
  puts "The frequency of gestation for others is:"
  p other_prglength_frequency
  return nil
end

def ex_2_4
  lifetime = [1, 2, 2, 3, 5]

  pmf = Ratistics.frequency(lifetime)
  puts "The frequency of object lifetimes is #{pmf}"

  pmf = Ratistics.probability(lifetime)
  puts "The Probability Mean Function of object lifetimes is #{pmf}"

  pmf_of_2_yrs = pmf.select{|age, probability| age >= 2}
  pmf_of_2_yrs = Ratistics.normalize_probability(pmf_of_2_yrs)
  puts "The lifetime PMF of a 2 year-old object is #{pmf_of_2_yrs}"
  return nil
end

def ex_2_5
  lifetime = [1, 2, 2, 3, 5]

  pmf = Ratistics.probability(lifetime)
  puts "The Probability Mean Function of object lifetimes is #{pmf}"

  pmf_mean = Ratistics.probability_mean(pmf)
  pmf_variance = Ratistics.probability_variance(pmf)

  puts "The probability mean is #{pmf_mean}"
  puts "The probability variance is #{pmf_variance}"
  return nil
end
