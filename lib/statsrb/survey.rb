module Statsrb
  module Survey
    extend self

    FEMRESP = File.expand_path(File.join(File.dirname(__FILE__), '../../data', '2002FemResp.dat'))
    FEMPREG = File.expand_path(File.join(File.dirname(__FILE__), '../../data', '2002FemPreg.dat'))

    def read

      ## open the femals respondents file
      #count = 0
      #File.foreach(FEMRESP) do |s|
        #count = count + 1
      #end
      #puts "Number of respondents: #{count}"

      # open the femals respondents file
      count = 0
      Zlib::GzipReader.open(Statsrb::Survey::FEMRESP + '.gz') do |gz|
        gz.each_line do |line|
          count = count + 1
        end
      end
      puts "Number of respondents: #{count}"

      ## open the femals pregnancies file
      #count = 0
      #File.foreach(FEMPREG) do |s|
        #count = count + 1
      #end
      #puts "Number of pregnancies: #{count}"

      # open the femals pregnancies file
      count = 0
      Zlib::GzipReader.open(Statsrb::Survey::FEMPREG + '.gz') do |gz|
        gz.each_line do |line|
          count = count + 1
        end
      end
      puts "Number of pregnancies: #{count}"

    end

  end
end
