require 'ratistics/collection'
require 'ratistics/rank'

module Ratistics

  # A read-only, memoized class for calculating percentile statistics
  # against a data sample.
  class Percentiles

    attr_reader :data

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

      @data = Collection.collect(data, &block)
      @data.sort! unless block_given? || opts[:sorted] == true
      @data.freeze

      @ranks = {}
      @percentiles = {}
      @percent_ranks = {}
      @nearest_ranks = {}
      @linear_ranks = {}
    end

    def ranks(opts={})
      as = opts[:as] || :hash
      @ranks[as] ||= Rank.ranks(@data, :sorted => true, :as => as).freeze
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

    # Iterate over the encapsulated sample and the associated percentiles.
    #
    # @yield iterates over each element in the data sample.
    # @yieldparam rank the rank from the data sample
    # @yieldparam percentile the percentile from the data sample
    def each(&block)
      ranks(:as => :array).each do |rank|
        yield(rank.first, rank.last)
      end
    end

    # Iterate over the encapsulated sample and the associated percent ranks.
    #
    # @yield iterates over each element in the data sample.
    # @yieldparam index the statistical (1-based) index of the sample
    # @yieldparam percent the percent rank of the value at the index
    def each_percent_rank(&block)
      (1..@data.size).each do |index|
        yield(index, percent_rank(index))
      end
    end

    # Iterate over the given range of percentile values (defaults to
    # 1 through 99) and returns the percentile and associated linear rank.
    #
    # @yield iterates over each element in the data sample.
    # @yieldparam rank the rank from the data sample
    # @yieldparam percentile the percentile from the data sample
    def each_with_linear_rank(range=nil, &block)
      range = (1..99) if range.nil?
      range = (1..range.max) if range.min < 1
      range = (range.min..99) if range.max > 99

      range.each do |percentile|
        yield(percentile, linear_rank(percentile))
      end
    end

    # Iterate over the given range of percentile values (defaults to
    # 1 through 99) and returns each percentile and associated nearest rank.
    #
    # @yield iterates over each element in the data sample.
    # @yieldparam rank the rank from the data sample
    # @yieldparam percentile the percentile from the data sample
    def each_with_nearest_rank(range=nil, &block)
      range = (1..99) if range.nil?
      range = (1..range.max) if range.min < 1
      range = (range.min..99) if range.max > 99

      range.each do |percentile|
        yield(percentile, nearest_rank(percentile))
      end
    end

    # Iterate over all integer ranks from the sample minimum (rounded
    # down) and the sample maximum (rounded up) and returns each rank
    # and the associated percentile.
    #
    # @yield iterates over each element in the data sample.
    # @yieldparam rank the rank from the data sample
    # @yieldparam percentile the percentile from the data sample
    def each_rank_and_percentile(&block)
      (@data.first.floor..@data.last.ceil).each do |rank|
        yield(rank, percentile(rank))
      end
    end
  end
end
