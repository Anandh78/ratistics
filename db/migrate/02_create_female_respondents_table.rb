require 'active_record'

class CreateFemaleRespondentsTable < ActiveRecord::Migration
  def self.up
    create_table :female_respondents do |t|
      t.column 'caseid', :int
    end
  end

  def self.down
    drop_table :female_respondents
  end
end  
