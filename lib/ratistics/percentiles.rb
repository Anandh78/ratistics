require 'ratistics/rank'

module Ratistics

  # A read-only, memoized class for calculating percentile statistics
  # against a data sample.
  class Percentiles

    attr_reader :ranks

    # Creates a new Percentiles object.
    #
    # When a block is provided a new collection is constructed
    # by enumerating the original data set and applying the block
    # to each item. Otherwise a reference to the original collection
    # is retained.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Objects, Enumerable] data the data set to aggregate
    # @param [Block] block optional block for per-item processing
    def initialize(data, opts={}, &block)
      raise ArgumentError.new('data cannot be nil') if data.nil?
      if block_given?
        @data = []
        data.each do |item|
          @data << yield(item)
        end
      elsif opts[:sorted] == true
        @data = data
      else 
        @data = data.sort
      end

      @ranks = Rank.ranks(@data, {:sorted => true}).freeze
      @ranks ||= []

      @percentiles = {}
      @percent_ranks = {}
      @nearest_ranks = {}
      @linear_ranks = {}
    end

    # Return the percentile of the given value.
    #
    # {Rank#percentile}
    def percentile(value)
      @percentiles[value] ||= Rank.percentile(@data, value, :sorted => true)
    end

    alias :centile :percentile

    # Calculate the percent rank for the given index within the sorted
    # data set.
    #
    # {Rank#percent_rank}
    def percent_rank(index)
      @percent_ranks[index] ||= Rank.percent_rank(@data, index, :sorted => true)
    end

    alias :percentile_rank :percent_rank

    # Return the percentile rank nearest to the given percentile.
    #
    # {Rank#nearest_rank}
    def nearest_rank(percentile, opts={})
      opts = opts.merge(:sorted => true)
      @nearest_ranks[percentile] ||= Rank.nearest_rank(@data, percentile, opts)
    end

    # Return the percentile rank nearest to the given percentile using
    # linear interpolation between closest ranks 
    #
    # {Rank#linear_rank}
    def linear_rank(percentile, opts={})
      opts = opts.merge(:sorted => true)
      @linear_ranks[percentile] ||= Rank.linear_rank(@data, percentile, opts)
    end

    alias :linear_interpolation_rank :linear_rank

    # Calculate the value representing the upper-bound of the first
    # quartile (percentile) of a data sample.
    #
    # {Rank#first_quartile}
    def first_quartile
      @first_quartile ||= Rank.first_quartile(@data)
    end

    alias :lower_quartile :first_quartile

    # Calculate the value representing the upper-bound of the second
    # quartile (percentile) of a data sample.
    #
    # {Rank#second_quartile}
    def second_quartile
      @second_quartile ||= Rank.second_quartile(@data)
    end

    # Calculate the value representing the upper-bound of the third
    # quartile (percentile) of a data sample.
    #
    # {Rank#third_quartile}
    def third_quartile
      @third_quartile ||= Rank.third_quartile(@data)
    end

    alias :upper_quartile :third_quartile

    # Iterate over the encapsulated sample.
    #
    # @yield iterates over each element in the data sample.
    # @yieldparam rank the rank from the data sample
    # @yieldparam percentils the percentile from the data sample
    def each(&block)
      ranks.each do |rank|
        yield(rank.first, rank.last)
      end
    end

    #def each_percentile(&block)
    #end

  end
end
