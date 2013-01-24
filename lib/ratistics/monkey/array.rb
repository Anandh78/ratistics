require 'ratistics'

module Ratistics

  class ::Array

    def mean(&block)
      return Ratistics.mean(self, &block)
    end

    alias :avg :mean
    alias :average :mean

    def truncated_mean(truncation, sorted=false, &block)
      return Ratistics.truncated_mean(self, truncation, sorted, &block)
    end

    def median(sorted=false, &block)
      return Ratistics.median(self, sorted, &block)
    end

    def mode(&block)
      return Ratistics.mode(self, &block)
    end

    def variance(mu=nil, &block)
      return Ratistics.variance(self, mu, &block)
    end

    alias :var :variance

    def standard_deviation(mu=nil, &block)
      return Ratistics.standard_deviation(self, mu, &block)
    end

    alias :std_dev :standard_deviation
    alias :stddev :standard_deviation

    def range(sorted=false, &block)
      return Ratistics.range(self, sorted, &block)
    end

    def frequency(&block)
      return Ratistics.frequency(self, &block)
    end

    def probability(&block)
      return Ratistics.probability(self, &block)
    end

    alias :pmf :probability

    def probability_mean(&block)
      return Ratistics.probability_mean(self, &block)
    end

    alias :pmf_mean :probability_mean

    def probability_variance(&block)
      return Ratistics.probability_variance(self, &block)
    end

    alias :pmf_variance :probability_variance

  end
end
