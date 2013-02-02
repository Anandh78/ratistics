# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 3) do

  create_table "female_respondents", :force => true do |t|
    t.integer "caseid"
  end

  create_table "pregnancies", :force => true do |t|
    t.integer "caseid"
    t.integer "nbrnaliv"
    t.integer "babysex"
    t.integer "birthwgt_lb"
    t.integer "birthwgt_oz"
    t.integer "prglength"
    t.integer "outcome"
    t.integer "birthord"
    t.integer "agepreg"
    t.float   "finalwgt"
  end

  create_table "racers", :force => true do |t|
    t.integer "place"
    t.string  "div_tot"
    t.string  "div"
    t.string  "guntime"
    t.string  "nettime"
    t.string  "pace"
    t.string  "name"
    t.integer "age"
    t.string  "gender"
    t.integer "race_num"
    t.integer "city_state"
  end

end
