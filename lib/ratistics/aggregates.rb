require 'ratistics/central_tendency'
require 'ratistics/collection'
require 'ratistics/distribution'

module Ratistics

  # A read-only, memoized class for calculating aggregate statistics
  # (central_tendency, central tendency, distribution) against a data sample.
  class Aggregates

    attr_reader :data

    # Creates a new Aggregates object.
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
      @data = Collection.collect(data, &block).freeze

      @truncated_means = {}
      @standard_deviations = {}
      @variances = {}
      @cdf = {}
    end

    # Returns the number of elements in the sample. May be zero. 
    #
    # @return the number of elements in the sample
    def length
      @length ||= @data.length
    end

    alias :size :length

    # Returns the number of items in the sample. Returns #length when no
    # arguments are given. If an argument is given, counts the number of
    # items in the sample which are equal to *item*. If a block is given,
    # counts the number of elements yielding a true value.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Object] item the (optional) item that is being counted or nil
    #   when counting the entire sample
    #
    # @return [Integer] the count
    def count(item=nil)
      count = 0

      if ! item.nil?
        @data.each do |datum|
          count += 1 if datum == item
        end
      elsif block_given?
        @data.each do |datum|
          count += 1 if yield(datum)
        end
      else
        count = @data.length
      end

      return count
    end

    # Calculates the statistical mean.
    #
    # {CentralTendency#mean}
    def mean
      @mean ||= CentralTendency.mean(@data)
    end

    alias :avg :mean
    alias :central_tendency :mean

    # Calculates a truncated statistical mean.
    #
    # {CentralTendency#truncated_mean}
    def truncated_mean(truncation=nil)
      @truncated_means[truncation] ||= CentralTendency.truncated_mean(@data, truncation)
    end

    alias :trimmed_mean :truncated_mean

    # Calculates the statistical midrange.
    #
    # {CentralTendency#midrange}
    def midrange
      @midrange ||= CentralTendency.midrange(@data)
    end

    alias :midextreme :midrange

    # Calculates the statistical median.
    #
    # {CentralTendency#median}
    def median
      @median ||= CentralTendency.median(@data)
    end

    # Calculates the statistical modes.
    #
    # {CentralTendency#mode}
    def mode
      @mode ||= CentralTendency.mode(@data)
    end

    # Calculates the statistical standard_deviations.
    #
    # {Distribution#standard_deviation}
    def standard_deviation(mu=nil)
      @standard_deviations[mu] ||= Distribution.standard_deviation(@data, mu)
    end

    alias :std_dev :standard_deviation
    alias :stddev :standard_deviation

    # Calculates the statistical variances.
    #
    # {Distribution#variance}
    def variance(mu=nil)
      @variances[mu] ||= Distribution.variance(@data, mu)
    end

    alias :var :variance

    # Calculates the statistical ranges.
    #
    # {Distribution#range}
    def range
      @range ||= Distribution.range(@data)
    end
  end
end
