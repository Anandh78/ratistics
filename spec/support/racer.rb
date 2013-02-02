require  'active_record'

class Racer < ActiveRecord::Base

  def self.connect(path=nil)
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => path || "#{File.dirname(__FILE__)}/../data/race.sqlite3",
      :pool => 5,
      :timeout => 5000
    )
  end
end
