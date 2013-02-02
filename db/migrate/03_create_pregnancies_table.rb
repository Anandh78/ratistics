require 'active_record'

class CreatePregnanciesTable < ActiveRecord::Migration
  def self.up
    create_table :pregnancies do |t|
      t.column 'caseid', :int
      t.column 'nbrnaliv', :int
      t.column 'babysex', :int
      t.column 'birthwgt_lb', :int
      t.column 'birthwgt_oz', :int
      t.column 'prglength', :int
      t.column 'outcome', :int
      t.column 'birthord', :int
      t.column 'agepreg', :int
      t.column 'finalwgt', :float
    end
  end

  def self.down
    drop_table :pregnancies
  end
end  
