require 'ratistics'

module Ratistics

  class ::Array

    # @see Average::mean
    def mean(*args, &block)
      return Ratistics.mean(self, *args, &block)
    end

    alias :avg :mean
    alias :average :mean

    # @see Average::truncated_mean
    def truncated_mean(*args, &block)
      return Ratistics.truncated_mean(self, *args, &block)
    end

    alias :trimmed_mean :truncated_mean

    # @see Average::midrange
    def midrange(*args, &block)
      return Ratistics.midrange(self, *args, &block)
    end

    alias :midextreme :midrange

    # @see Average::median
    def median(*args, &block)
      return Ratistics.median(self, *args, &block)
    end

    # @see Average::mode
    def mode(*args, &block)
      return Ratistics.mode(self, *args, &block)
    end

    # @see Distribution::variance
    def variance(*args, &block)
      return Ratistics.variance(self, *args, &block)
    end

    alias :var :variance

    # @see Distribution::standard_deviation
    def standard_deviation(*args, &block)
      return Ratistics.standard_deviation(self, *args, &block)
    end

    alias :std_dev :standard_deviation
    alias :stddev :standard_deviation

    # @see Distribution::range
    def range(*args, &block)
      return Ratistics.range(self, *args, &block)
    end

    # @see Probability::frequency
    def frequency(*args, &block)
      return Ratistics.frequency(self, *args, &block)
    end

    # @see Probability::probability
    def probability(*args, &block)
      return Ratistics.probability(self, *args, &block)
    end

    alias :pmf :probability

    # @see Probability::probability_mean
    def probability_mean(*args, &block)
      return Ratistics.probability_mean(self, *args, &block)
    end

    alias :pmf_mean :probability_mean

    # @see Probability::probability_variance
    def probability_variance(*args, &block)
      return Ratistics.probability_variance(self, *args, &block)
    end

    alias :pmf_variance :probability_variance

    # @see Rank::percentiles
    def ranks(*args, &block)
      return Ratistics.ranks(self, *args, &block)
    end

    alias :percentiles :ranks
    alias :centiles :ranks

    # @see Rank::percent_rank
    def percent_rank(*args, &block)
      return Ratistics.percent_rank(self, *args, &block)
    end

    # @see Rank::linear_rank
    def linear_rank(*args, &block)
      return Ratistics.linear_rank(self, *args, &block)
    end

    alias :percentile :linear_rank
    alias :centile :linear_rank

    # @see Rank::nearest_rank
    def nearest_rank(*args, &block)
      return Ratistics.nearest_rank(self, *args, &block)
    end

    # @see Collection::ascending?
    def ascending?(*args, &block)
      return Ratistics.ascending?(self, *args, &block)
    end

    # @see Collection::descending?
    def descending(*args, &block)
      return Ratistics.descending?(self, *args, &block)
    end

    # @see Collection::binary_search
    def binary_search(*args, &block)
      return Ratistics.binary_search(self, *args, &block)
    end

    alias :bsearch :binary_search
    alias :half_interval_search :binary_search

    # @see Collection::ascending?
    def ascending?(*args, &block)
      return Ratistics.ascending?(self, *args, &block)
    end

    # @see Collection::descending?
    def descending?(*args, &block)
      return Ratistics.descending?(self, *args, &block)
    end

  end
end
