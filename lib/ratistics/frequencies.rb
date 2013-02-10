require 'ratistics/probability'

module Ratistics

  class Frequencies

    attr_reader :distribution

    alias :frequency :distribution
    alias :frequencies :distribution

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
    # @param [Objects, Enumerable] args the data set calculate frequencies for
    # @param [Block] block optional block for per-item processing
    def initialize(*args, &block)
      if args.nil? || args.size == 0 || (args.size == 1 && args.first.nil?)
        raise ArgumentError.new('data cannot be nil') 
      end
      @distribution = Probability.frequency([args].flatten, &block).freeze
      @distribution ||= {}
    end

    # Calculate the mean from a frequency distribution.
    #
    # {Probability#frequency_mean}
    def frequency_mean
      @mean ||= Probability.frequency_mean(distribution)
    end

    alias :mean :frequency_mean

    # Calculates the statistical probability.
    #
    # {Probability#probability}
    def probability
      @probability ||= Probability.probability(distribution).freeze
    end

    alias :pmf :probability
    alias :probabilities :probability

    # Calculates the statistical mean of a probability distribution.
    # 
    # {Probability#probability_mean}
    def probability_mean
      @probability_mean ||= Probability.probability_mean(probability)
    end

    alias :pmf_mean :probability_mean

    # Calculates the statistical variance of a probability distribution.
    #
    # {Probability#probability_variance}
    def probability_variance
      @probability_variance ||= Probability.probability_variance(probability)
    end

    alias :pmf_variance :probability_variance

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
