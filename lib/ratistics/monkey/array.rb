require 'ratistics'

module Ratistics

  class ::Array

    # @see Average::mean
    def mean(&block)
      return Ratistics.mean(self, &block)
    end

    alias :avg :mean
    alias :average :mean

    # @see Average::truncated_mean
    def truncated_mean(truncation, sorted=false, &block)
      return Ratistics.truncated_mean(self, truncation, sorted, &block)
    end

    # @see Average::median
    def median(&block)
      return Ratistics.median(self, false, &block)
    end

    # @see Average::mode
    def mode(&block)
      return Ratistics.mode(self, &block)
    end

    # @see Distribution::variance
    def variance(mu=nil, &block)
      return Ratistics.variance(self, mu, &block)
    end

    alias :var :variance

    # @see Distribution::standard_deviation
    def standard_deviation(mu=nil, &block)
      return Ratistics.standard_deviation(self, mu, &block)
    end

    alias :std_dev :standard_deviation
    alias :stddev :standard_deviation

    # @see Distribution::range
    def range(&block)
      return Ratistics.range(self, false, &block)
    end

    # @see Probability::frequency
    def frequency(&block)
      return Ratistics.frequency(self, &block)
    end

    # @see Probability::probability
    def probability(&block)
      return Ratistics.probability(self, &block)
    end

    alias :pmf :probability

    # @see Probability::probability_mean
    def probability_mean(&block)
      return Ratistics.probability_mean(self, &block)
    end

    alias :pmf_mean :probability_mean

    # @see Probability::probability_variance
    def probability_variance(&block)
      return Ratistics.probability_variance(self, &block)
    end

    alias :pmf_variance :probability_variance

  end
end
