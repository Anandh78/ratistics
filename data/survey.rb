require 'zlib'
require 'hamster/vector'
require 'csv'

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
          record[definition[index][0]] = row[index]
        end
      data = data.cons(record.freeze)
    end

    return data
  end
end
