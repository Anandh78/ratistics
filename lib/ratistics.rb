$:.push File.join(File.dirname(__FILE__))

require 'ratistics/average'
require 'ratistics/distribution'
require 'ratistics/functions'
require 'ratistics/probability_mass_function'
require 'ratistics/version'

module Ratistics
  class << self
    include Average
    include Distribution
    include Functions
    include ProbabilityMassFunction
  end
end
