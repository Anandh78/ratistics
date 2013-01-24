require 'zlib'
require 'hamster/vector'

module Survey
  extend self

  FEMRESP = File.expand_path(File.join(File.dirname(__FILE__), '2002FemResp.dat.gz'))
  FEMPREG = File.expand_path(File.join(File.dirname(__FILE__), '2002FemPreg.dat.gz'))

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

  def get_respondent_data
    @@respondents ||= load_file(Survey::FEMRESP, Survey::RESPONDENT_FIELDS)
  end

  def get_pregnancy_data
    @@pregnancies ||= load_file(Survey::FEMPREG, Survey::PREGNANCY_FIELDS)
  end

  def get_counts
    respondents = load_respondent_data
    puts "Number of respondents: #{respondents.count}"

    pregnancies = load_pregnancy_data
    puts "Number of pregnancies: #{pregnancies.count}"
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
end
