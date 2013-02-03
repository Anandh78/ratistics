require 'ratistics/average'
require 'ratistics/distribution'
require 'ratistics/functions'
require 'ratistics/load'
require 'ratistics/probability'
require 'ratistics/rank'
require 'ratistics/version'

module Ratistics
  class << self
    include Average
    include Distribution
    include Functions
    include Probability
    include Rank
  end
end
