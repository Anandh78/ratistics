$:.push File.join(File.dirname(__FILE__))

require 'ratistics/average'
require 'ratistics/distribution'
require 'ratistics/histogram'
require 'ratistics/version'

module Ratistics
  class << self
    include Average
    include Distribution
    include Histogram
  end

  #begin
    #require 'hamster'
    #ARRAY_CLASS = Hamster::Vector
    #HASH_CLASS = Hamster::Hash
  #rescue LoadError
    #ARRAY_CLASS = Array
    #HASH_CLASS = Hash
  #end

  #def self.array
    #return ARRAY_CLASS.new
  #end

  #def self.hash
    #return HASH_CLASS.new
  #end

end
