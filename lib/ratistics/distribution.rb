require 'ratistics/central_tendency'

module Ratistics

  # Various distribution computation functions.
  module Distribution
    extend self

    # Calculates the statistical variance.
    #
    # When a block is given the block will be applied to every
    # element in the data set. Using a block in this way allows
    # probability to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to compute the variance of
    # @param [Float] mu datum around which to compute the variance,
    #   defaults to the statistical mean of the sample
    # @param [Block] block optional block for per-item processing
    #
    # @return [Float, 0] the statistical variance of the given data set
    #   or zero if the data set is empty
    def variance(data, mu=nil, opts={}, &block)
      return 0 if data.nil? || data.empty?

      mu = CentralTendency.mean(data, &block) if mu.nil?

      deviation = data.reduce([]) do |memo, datum|
        datum = yield(datum) if block_given?
        memo << (datum.to_f - mu) ** 2
      end

      variance = CentralTendency.mean(deviation)
      return variance
    end

    alias :var :variance

    # Calculates the statistical standard deviation.
    #
    # When a block is given the block will be applied to every
    # element in the data set. Using a block in this way allows
    # probability to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to compute the standard
    #   deviation of
    # @param [Float] mu datum around which to compute the standard
    #   deviation, defaults to the statistical mean of the sample
    # @param [Block] block optional block for per-item processing
    #
    # @return [Float, 0] the standard deviation of the given data set
    #   or zero if the data set is empty
    def standard_deviation(data, mu=nil, opts={}, &block)
      return 0 if data.nil? || data.empty?
      return ::Math.sqrt(variance(data, mu, &block))
    end

    alias :std_dev :standard_deviation
    alias :stddev :standard_deviation

    # Calculates the statistical range.
    #
    # Will sort the data set using natural sort order unless
    # the :sorted option is true or a block is given.
    #
    # When a block is given the block will be applied to every
    # element in the data set. Using a block in this way allows
    # probability to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to compute the range of
    #
    # @option opts [true, false] :sorted indicates of the data is already sorted
    #
    # @return [Float, 0] the statistical range of the given data set
    #   or zero if the data set is empty
    def range(data, opts={})
      return 0 if data.nil? || data.count <= 1
      data = data.sort unless block_given? || opts[:sorted] == true

      if block_given?
        range = yield(data.last) - yield(data.first)
      else
        range = data.last - data.first
      end

      return range
    end
  end
end
