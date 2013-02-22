require 'ratistics/probability'

module Ratistics

  # A read-only, memoized class for calculating frequency and
  # probability statistics against a data sample.
  class Frequencies

    # Creates a new Frequencies object
    #
    # When a block is provided a new collection is constructed
    # by enumerating the original data set and applying the block
    # to each item. Otherwise a reference to the original collection
    # is retained.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Objects, Enumerable] data the data set calculate frequencies for
    # @param [Block] block optional block for per-item processing
    #   (default :hash)
    def initialize(data, opts={}, &block)
      raise ArgumentError.new('data cannot be nil') if data.nil?
      @distribution = {}
      @distribution[:hash] = Probability.frequency(data, &block).freeze
      @distribution[:hash] ||= {}.freeze
    end

    # Returns the frequency distribution for the data sample.
    #
    # @option opts [Symbol] :as sets the output to :hash or :array
    #
    # @return (see Probability#frequency)
    def distribution(opts={})
      if opts[:as].nil? || opts[:as] == :hash
        @distribution[:hash]
      elsif opts[:as] == :array
        @distribution[:array] ||= @distribution[:hash].reduce([]) do |memo, frequency|
          memo << frequency
        end.freeze
      else
        raise ArgumentError.new("Unrecognized return type #{opts[:as]}")
      end
    end

    alias :frequency :distribution
    alias :frequencies :distribution

    # Calculate the mean from a frequency distribution.
    #
    # {Probability#frequency_mean}
    def frequency_mean
      @mean ||= Probability.frequency_mean(distribution, :from => :frequency)
    end

    alias :mean :frequency_mean

    # Calculates the statistical probability.
    #
    # {Probability#probability}
    def probability
      @probability ||= Probability.probability(distribution, :from => :frequency).freeze
    end

    alias :pmf :probability
    alias :probabilities :probability

    # Calculates the statistical mean of a probability distribution.
    # 
    # {Probability#probability_mean}
    def probability_mean
      @probability_mean ||= Probability.probability_mean(probability, :from => :probability)
    end

    alias :pmf_mean :probability_mean

    # Calculates the statistical variance of a probability distribution.
    #
    # {Probability#probability_variance}
    def probability_variance
      @probability_variance ||= Probability.probability_variance(probability, :from => :probability)
    end

    alias :pmf_variance :probability_variance

    # Calculates the cumulative distribution function (CDF) of a probability
    # distribution.
    #
    # {Probability#cumulative_distribution_function}
    def cumulative_distribution_function(value)
      @cdf[value] ||= Probability.cumulative_distribution_function(frequency, value, :from => :freq)
    end

    alias :cdf :cumulative_distribution_function
    alias :cumulative_distribution :cumulative_distribution_function

    # Returns the frequency of occurency for the given value. Returns zero
    # if the value was not in the original data sample.
    #
    # @param [Object] value the value to find the frequency of
    #
    # @return [Integer] the frequency or zero
    def frequency_of(value)
      distribution[value] || 0
    end

    alias :of :frequency_of

    # Returns the probability of occurency for the given value. Returns zero
    # if the value was not in the original data sample.
    #
    # @param [Object] value the value to find the probability of
    #
    # @return [Integer] the probability or zero
    def probability_of(value)
      probability[value] || 0
    end

    # Iterate over the encapsulated sample.
    #
    # @yield iterates over each element in the data sample.
    # @yieldparam value the value from the data sample
    # @yieldparam frequency the frequency of the value
    # @yieldparam probability the probability of the value
    def each(&block)
      distribution.each do |value, frequency|
        yield(value, frequency, probability[value])
      end
    end

    # Iterate over the encapsulated sample.
    #
    # @yield iterates over each element in the data sample.
    # @yieldparam value the value from the data sample
    def each_value(&block)
      distribution.each do |value, frequency|
        yield(value)
      end
    end

    # Iterate over the encapsulated sample.
    #
    # @yield iterates over each element in the data sample.
    # @yieldparam frequency a frequency from the distribution
    def each_frequency(&block)
      distribution.each do |value, frequency|
        yield(frequency)
      end
    end

    # Iterate over the encapsulated sample.
    #
    # @yield iterates over each element in the data sample.
    # @yieldparam frequency a probability from the distribution
    def each_probability(&block)
      probability.each do |value, prob|
        yield(prob)
      end
    end

  end
end
