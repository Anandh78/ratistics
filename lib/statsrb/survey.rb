module Statsrb
  module Survey
    extend self

    FEMRESP = File.expand_path(File.join(File.dirname(__FILE__), '../../data', '2002FemResp.dat.gz'))
    FEMPREG = File.expand_path(File.join(File.dirname(__FILE__), '../../data', '2002FemPreg.dat.gz'))

    def read

      # open the femaile respondents file
      count = 0
      Zlib::GzipReader.open(Statsrb::Survey::FEMRESP) do |gz|
        gz.each_line do |line|
          count = count + 1
        end
      end
      puts "Number of respondents: #{count}"

      # open the femaile pregnancies file
      count = 0
      Zlib::GzipReader.open(Statsrb::Survey::FEMPREG) do |gz|
        gz.each_line do |line|
          count = count + 1
        end
      end
      puts "Number of pregnancies: #{count}"

    end

  end
end
