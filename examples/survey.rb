require 'zlib'
require 'hamster/vector'
require 'csv'


# sample = [5, 1, 9, 3, 14, 9, 7]
#
#  1 - 7/0/1/7.142857142857142
#  2 - 7/1/0/14.285714285714285
#  3 - 7/1/1/21.428571428571427
#  4 - 7/2/0/28.57142857142857
#  5 - 7/2/1/35.714285714285715
#  6 - 7/3/0/42.857142857142854
#  7 - 7/3/1/50
#  8 - 7/4/0/57.14285714285714
#  9 - 7/4/2/71.42857142857143
# 10 - 7/6/0/85.71428571428571
# 11 - 7/6/0/85.71428571428571
# 12 - 7/6/0/85.71428571428571
# 13 - 7/6/0/85.71428571428571
# 14 - 7/6/1/92.85714285714286
#
# sample = [40, 15, 35, 20, 40, 50]
#
#  5 - 6/0/0/0
# 10 - 6/0/0/0
# 15 - 6/0/1/8.333333333333332
# 20 - 6/1/1/25
# 25 - 6/2/0/33.33333333333333
# 30 - 6/2/0/33.33333333333333
# 35 - 6/2/1/41.66666666666667
# 40 - 6/3/2/66.66666666666666
# 45 - 6/5/0/83.33333333333334
# 50 - 6/5/1/91.66666666666666
# 55 - 6/6/0/100  
#
# sample = [1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,3,4,4,5,6]
#
# 1 - 22/0/5/11.363636363636363
# 2 - 22/5/8/40.909090909090914
# 3 - 22/13/5/70.45454545454545
# 4 - 22/18/2/86.36363636363636
# 5 - 22/20/1/93.18181818181817
# 6 - 22/21/1/97.72727272727273
#
# Formula:
# PR% = L + ( 0.5 x S ) / N 
#
# Where,
# L = Number of below rank, 
# S = Number of same rank,
# N = Total numbers.

module Survey
  extend self

  FEMRESP_RAW = File.expand_path(File.join(File.dirname(__FILE__), '2002FemResp.dat.gz'))
  FEMRESP_CSV = File.expand_path(File.join(File.dirname(__FILE__), '2002FemResp.csv'))

  FEMPREG_RAW = File.expand_path(File.join(File.dirname(__FILE__), '2002FemPreg.dat.gz'))
  FEMPREG_CSV = File.expand_path(File.join(File.dirname(__FILE__), '2002FemPreg.csv'))

  RACE_RAW = File.expand_path(File.join(File.dirname(__FILE__), 'race.dat.gz'))
  RACE_CSV = File.expand_path(File.join(File.dirname(__FILE__), 'race.csv'))

  RESPONDENT_FIELDS = [
    [:caseid, 1, 12, :to_i].freeze,
  ].freeze

  PREGNANCY_FIELDS = [
    [:caseid, 1, 12, :to_i].freeze,
    [:nbrnaliv, 22, 22, :to_i].freeze,
    [:babysex, 56, 56, :to_i].freeze,
    [:birthwgt_lb, 57, 58, :to_i].freeze,
    [:birthwgt_oz, 59, 60, :to_i].freeze,
    [:prglength, 275, 276, :to_i].freeze,
    [:outcome, 277, 277, :to_i].freeze,
    [:birthord, 278, 279, :to_i].freeze,
    [:agepreg, 284, 287, :to_i].freeze,
    [:finalwgt, 423, 440, :to_f].freeze,
  ].freeze

  RACE_FIELDS = [
    [:place, 1, 6, :to_i].freeze,
    [:div_tot, 7, 15, :strip].freeze,
    [:string, 16, 21, :strip].freeze,
    [:guntime, 22, 29, :strip].freeze,
    [:nettime, 30, 38, :strip].freeze,
    [:pace, 39, 44, :strip].freeze,
    [:name, 45, 67, :strip].freeze,
    [:age, 68, 70, :to_i].freeze,
    [:gender, 71, 72, :strip].freeze,
    [:race_num, 73, 78, :to_i].freeze,
    [:location, 79, 101, :strip].freeze,
  ].freeze

  def get_respondent_data
    @@respondents ||= load_file(Survey::FEMRESP_RAW, Survey::RESPONDENT_FIELDS)
  end

  def get_pregnancy_data
    @@pregnancies ||= load_file(Survey::FEMPREG_RAW, Survey::PREGNANCY_FIELDS)
  end

  def get_race_data
    @@race ||= load_file(Survey::RACE_RAW, Survey::RACE_FIELDS)
  end

  def load_respondent_csv
    @@respondents_csv ||= load_csv(Survey::FEMRESP_CSV, Survey::RESPONDENT_FIELDS)
  end

  def load_pregnancy_csv
    @@pregnancies_csv ||= load_csv(Survey::FEMPREG_CSV, Survey::PREGNANCY_FIELDS)
  end

  def load_race_csv
    @@race_csv ||= load_csv(Survey::RACE_CSV, Survey::RACE_FIELDS)
  end

  def get_counts
    respondents = get_respondent_data
    puts "Number of respondents: #{respondents.count}"

    pregnancies = get_pregnancy_data
    puts "Number of pregnancies: #{pregnancies.count}"

    racers = get_race_data
    puts "Number of racers: #{racers.count}"
  end

  def load_file(path, definition)
    data = Hamster.vector

    Zlib::GzipReader.open(path) do |gz|
      gz.each_line do |line|
        record = {}
        definition.each do |field|
          record[field[0]] = line.slice(field[1]-1, field[2]-field[1]+1).send(field[3])
        end
        data = data.cons(record.freeze)
      end
    end

    return data
  end

  def load_csv(path, definition)
    data = Hamster.vector

    CSV.foreach(path) do |row|
      record = {}
      definition.each_index do |index|
        record[definition[index][0]] = row[index].send(definition[index][3])
      end
      data = data.cons(record.freeze)
    end

    return data
  end
end
