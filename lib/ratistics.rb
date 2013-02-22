require 'ratistics/inflect'

require 'ratistics/average'
require 'ratistics/collection'
require 'ratistics/distribution'
require 'ratistics/math'
require 'ratistics/load'
require 'ratistics/probability'
require 'ratistics/rank'
require 'ratistics/search'
require 'ratistics/sort'
require 'ratistics/version'

require 'ratistics/aggregates'
require 'ratistics/frequencies'
require 'ratistics/percentiles'

module Ratistics

  class NilSampleError < StandardError
    def initialize(msg=nil)
      msg = 'the sample cannot be nil' if msg.nil?
      super(msg)
    end
  end

  class << self
    include Average
    include Collection
    include Distribution
    include Inflect
    include Math
    include Probability
    include Rank
    include Search
    include Sort

    def aggregates(*args, &block)
      return Aggregates.new(*args, &block)
    end

    def frequencies(*args, &block)
      return Frequencies.new(*args, &block)
    end

    def percentiles(*args, &block)
      return Percentiles.new(*args, &block)
    end
  end
end
