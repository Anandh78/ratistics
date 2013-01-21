module Statsrb
  module Survey
    extend self

    FEMRESP = File.expand_path(File.join(File.dirname(__FILE__), '../../data', '2002FemResp.dat.gz'))
    FEMPREG = File.expand_path(File.join(File.dirname(__FILE__), '../../data', '2002FemPreg.dat.gz'))

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

    def read

      # open the femaile respondents file
      respondents = []
      Zlib::GzipReader.open(Statsrb::Survey::FEMRESP) do |gz|
        gz.each_line do |line|
          record = {}
          RESPONDENT_FIELDS.each do |field|
            record[field[0]] = line.slice(field[1]-1, field[2]-field[1]+1).send(field[3])
          end
          respondents << record
        end
      end
      puts "Number of respondents: #{respondents.count}"
      #pp respondents.last

      # open the femaile pregnancies file
      pregnancies = []
      Zlib::GzipReader.open(Statsrb::Survey::FEMPREG) do |gz|
        gz.each_line do |line|
          record = {}
          PREGNANCY_FIELDS.each do |field|
            record[field[0]] = line.slice(field[1]-1, field[2]-field[1]+1).send(field[3])
          end
          pregnancies << record
        end
      end
      puts "Number of pregnancies: #{pregnancies.count}"
      #puts pregnancies.last

    end

  end
end
