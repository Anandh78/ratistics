require 'ratistics/probability'

module Ratistics

  class Frequency

    attr_reader :distribution

    alias :frequency :distribution

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

    def probability_mean
      @probability_mean ||= Probability.probability_mean(probability)
    end

    alias :pmf_mean :probability_mean

    def probability_variance
      @probability_variance ||= Probability.probability_variance(probability)
    end

    alias :pmf_variance :probability_variance

  end
end
