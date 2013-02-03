require 'ratistics/average'
require 'ratistics/collection'
require 'ratistics/distribution'
require 'ratistics/math'
require 'ratistics/load'
require 'ratistics/probability'
require 'ratistics/rank'
require 'ratistics/version'

module Ratistics
  class << self
    include Average
    include Collection
    include Distribution
    include Math
    include Probability
    include Rank
  end
end
