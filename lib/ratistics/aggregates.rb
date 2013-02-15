require 'ratistics/average'
require 'ratistics/distribution'

module Ratistics

  # A read-only, memoized class for calculating aggregate statistics
  # (average, central tendency, distribution) against a data sample.
  class Aggregates

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
    # @param [Objects, Enumerable] args the data set to aggregate
    # @param [Block] block optional block for per-item processing
    def initialize(data, opts={}, &block)
      @data = data

      # use #each for maximum compatability
      if block_given?
        col = []
        @data.each{|item| col << yield(item) }
        @data = col
      end

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
    # @param [Block] block optional block for per-item processing
    #
    # @return [Integer] the count
    def count(item=nil, &block)
      count = 0

      if ! item.nil?
        @data.each do |datum|
          count = count + 1 if datum == item
        end
      elsif block_given?
        @data.each do |datum|
          count = count + 1 if yield(datum)
        end
      elsif @data.respond_to? :length
        count = @data.length
      else
        @data.each { count = count + 1 }
      end

      return count
    end

    # Calculates the statistical mean.
    #
    # {Average#mean}
    def mean
      @mean ||= Average.mean(@data)
    end

    alias :avg :mean
    alias :average :mean

    # Calculates a truncated statistical mean.
    #
    # {Average#truncated_mean}
    def truncated_mean(truncation=nil)
      @truncated_means[truncation] ||= Average.truncated_mean(@data, truncation)
    end

    alias :trimmed_mean :truncated_mean

    # Calculates the statistical midrange.
    #
    # {Average#midrange}
    def midrange
      @midrange ||= Average.midrange(@data)
    end

    alias :midextreme :midrange

    # Calculates the statistical median.
    #
    # {Average#median}
    def median
      @median ||= Average.median(@data)
    end

    # Calculates the statistical modes.
    #
    # {Average#mode}
    def mode
      @mode ||= Average.mode(@data)
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

    # Calculates the cumulative distribution function (CDF) of a probability
    # distribution.
    #
    # {Probability#cumulative_distribution_function}
    def cumulative_distribution_function(value)
      @cdf[value] ||= Probability.cumulative_distribution_function(@data, value)
    end

    alias :cdf :cumulative_distribution_function
    alias :cumulative_distribution :cumulative_distribution_function

  end
end
