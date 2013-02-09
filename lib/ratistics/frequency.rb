require 'ratistics/probability'

module Ratistics

  class Frequency

    attr_reader :distribution

    alias :frequency :distribution
    alias :frequencies :distribution

    def initialize(data, opts={}, &block)
      raise ArgumentError.new('data cannot be nil') if data.nil?
      @distribution = Probability.frequency(data, opts, &block).freeze
      @distribution ||= {}
    end

    def frequency_mean
      @mean ||= Probability.frequency_mean(distribution)
    end

    alias :mean :frequency_mean

    def probability
      @probability ||= Probability.probability(distribution).freeze
    end

    alias :pmf :probability
    alias :probabilities :probability

    def probability_mean
      @probability_mean ||= Probability.probability_mean(probability)
    end

    alias :pmf_mean :probability_mean

    def probability_variance
      @probability_variance ||= Probability.probability_variance(probability)
    end

    alias :pmf_variance :probability_variance

    def frequency_of(value)
      distribution[value] || 0
    end

    alias :of :frequency_of

    def probability_of(value)
      probability[value] || 0
    end

    def each(&block)
      distribution.each do |value, frequency|
        yield(value, frequency, probability[value])
      end
    end

    def each_value(&block)
      distribution.each do |value, frequency|
        yield(value)
      end
    end

    def each_frequency(&block)
      distribution.each do |value, frequency|
        yield(frequency)
      end
    end

    def each_probability(&block)
      probability.each do |value, prob|
        yield(prob)
      end
    end

  end
end
