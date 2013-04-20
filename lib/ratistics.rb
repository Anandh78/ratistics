require 'ratistics/inflect'

require 'ratistics/central_tendency'
require 'ratistics/collection'
require 'ratistics/distribution'
require 'ratistics/math'
require 'ratistics/load'
require 'ratistics/load/csv'
require 'ratistics/load/dat'
require 'ratistics/probability'
require 'ratistics/rank'
require 'ratistics/search'
require 'ratistics/sort'
require 'ratistics/version'

require 'ratistics/catalog'

Infinity = 1/0.0 unless defined?(Infinity)
NaN = 0/0.0 unless defined?(NaN)

module Ratistics

  class NilSampleError < StandardError
    def initialize(msg=nil)
      msg = 'the sample cannot be nil' if msg.nil?
      super(msg)
    end
  end

  class << self
    include CentralTendency
    include Collection
    include Distribution
    include Inflect
    include Math
    include Probability
    include Rank
    include Search
    include Sort
  end
end
