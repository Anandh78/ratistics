require 'active_record'

class CreateRacersTable < ActiveRecord::Migration
  def self.up
    create_table :racers do |t|
      t.column 'place', :int
      t.column 'div_tot', :string
      t.column 'div', :string
      t.column 'guntime', :string
      t.column 'nettime', :string
      t.column 'pace', :string
      t.column 'name', :string
      t.column 'age', :int
      t.column 'gender', :string
      t.column 'race_num', :int
      t.column 'city_state', :int
    end
  end

  def self.down
    drop_table :racers
  end
end  
