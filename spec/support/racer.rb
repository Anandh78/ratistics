jruby = (0 == (RbConfig::CONFIG['ruby_install_name']=~ /^jruby$/i))
windows = (RbConfig::CONFIG['host_os'] =~ /mswin32/i || RbConfig::CONFIG['host_os'] =~ /mingw32/i)
ar = !(jruby || windows)

require 'active_record' if ar
parent = ar ? ActiveRecord::Base : Class.new

class Racer < parent

  CSV_PATH = File.join(File.dirname(__FILE__), '../data/race.csv')
  DAT_PATH = File.join(File.dirname(__FILE__), '../data/race.dat')

  CSV_DEFINITION = [
    [:place, :to_i],
    :div_tot,
    :div,
    :guntime,
    :nettime,
    :pace,
    :name,
    [:age, :to_i],
    :gender,
    [:race_num, :to_i],
    :city_state
  ]

  DAT_DEFINITION = [
    {:field => :place, :start => 1, :end => 6, :cast => :to_i },
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

  def self.from_csv
    Ratistics::Load.csv_file(CSV_PATH, def: CSV_DEFINITION)
  end

  def self.from_dat
    Ratistics::Load.dat_file(DAT_PATH, DAT_DEFINITION)
  end

  if defined? ActiveRecord::Base
    def self.connect(path=nil)
      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3',
        :database => path || "#{File.dirname(__FILE__)}/../data/race.sqlite3",
        :pool => 5,
        :timeout => 5000
      )
    end
  end
end
