require 'ratistics/functions'

module Ratistics

  # Various probability computation functions.
  module Probability
    extend self

    # Calculates the statistical frequency.
    #
    # When a block is given the block will be applied to every
    # element in the data set. Using a block in this way allows
    # probability to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # For a block {|item| ... }
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to compute the frequency of
    # @param [Block] block optional block for per-item processing
    #
    # @return [Hash, nil] the statistical frequency of the given data set
    #   or nil if the data set is empty
    def frequency(data, opts={}, &block)
      return nil if data.nil? || data.empty?

      freq = data.reduce({}) do |memo, datum|
        datum = yield(datum) if block_given?
        memo[datum] = memo[datum].to_i + 1
        memo
      end

      return freq
    end

    # Calculate the mean from a frequency distribution.
    #
    # The data set must be formatted as output by the #frequency
    # method. Specifically, a hash where each hash key is a datum from
    # the original data set and each hash value is the frequency
    # associated with that datum.
    #
    # @see #frequency
    #
    # @param [Hash] data the frequency distribution to calculate
    #   the statistical mean of
    #
    # @return [Float, 0] the statistical mean of the given data set
    #   or zero if the data set is empty
    def frequency_mean(data, opts={}, &block)
      return 0 if data.nil? || data.empty?
      pmf = probability(data, &block)
      mean = probability_mean(pmf)
      return mean
    end

    # Calculates the statistical probability. Will operate on
    # an array of individual data values or a hash representing
    # a frequency distribution. The keys of the hash must be
    # the data values (may be complex data) and the values
    # must be the frequency values.
    #
    # When a block is given the block will be applied to every
    # element in the data set. Using a block in this way allows
    # probability to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # For a block {|item| ... }
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable, Hash] data the data set to compute the probability of
    # @param [Block] block optional block for per-item processing
    #
    # @return [Hash, nil] the statistical probability of the given data set
    #   or nil if the data set is empty
    def probability(data, opts={}, &block)
      return nil if data.nil? || data.empty?
      from_frequency = data.respond_to? :keys

      if from_frequency
        count = data.reduce(0) do |n, key, value|
          key, value = key if key.is_a? Array
          key = yield(key) if block_given?
          n + value
        end
      else
        count = data.count
        data = frequency(data, &block)
      end

      prob = data.reduce({}) do |memo, key, value|
        key, value = key if key.is_a? Array
        key = yield(key) if from_frequency && block_given?
        memo[key] = value.to_f / count.to_f
        memo
      end

      return prob
    end

    alias :pmf :probability

    # Normalize a probability distribution sample.
    #
    # The data set must be formatted as output by the #probability
    # method. Specifically, a hash where each hash key is a datum from
    # the original data set and each hash value is the probability
    # associated with that datum. A probability hash may become
    # denormalized when performing conditional probability.
    #
    # @see #probability
    #
    # @param [Hash] pmf the probability curve to normalize
    # 
    # @return [Hash] a new, normalized probability distribution.
    def normalize_probability(pmf, opts={})
      total = pmf.values.reduce(0.0){|n, value| n + value} 

      return { pmf.keys.first => 1 } if pmf.count == 1
      return pmf if Functions.delta(total, 1.0) < 0.01

      factor = 1.0 / total.to_f
      normalized = pmf.reduce({}) do |memo, pair|
        memo[pair[0]] = pair[1] * factor
        memo
      end
      return normalized
    end

    alias :normalize_pmf :normalize_probability

    # Calculates the statistical mean of a probability distribution.
    # Will operate on an array of individual data values or a
    # hash representing a probability distribution. The keys of
    # the hash must be the data values (may be complex data)
    # and the values must be the frequency values.
    #
    # When a block is given the block will be applied to every
    # element in the data set. Using a block in this way allows
    # probability to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # For a block {|item| ... }
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable, Hash] data the data set to compute the mean of
    # @param [Block] block optional block for per-item processing
    #
    # @return [Float, 0] the statistical mean of the given data set
    #   or zero if the data set is empty
    def probability_mean(data, opts={}, &block)
      return 0 if data.nil? || data.empty?
      from_probability = data.respond_to? :keys

      data = probability(data, &block) unless from_probability

      mean = data.reduce(0.0) do |n, key, value|
        key, value = key if key.is_a? Array
        key = yield(key) if from_probability and block_given?
        n + (key * value)
      end

      return mean
    end

    alias :pmf_mean :probability_mean

    # Calculates the statistical variance of a probability distribution.
    # Will operate on an array of individual data values or a
    # hash representing a probability distribution. The keys of
    # the hash must be the data values (may be complex data)
    # and the values must be the frequency values.
    #
    # When a block is given the block will be applied to every
    # element in the data set. Using a block in this way allows
    # probability to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # For a block {|item| ... }
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable, Hash] data the data set to compute the variance of
    # @param [Block] block optional block for per-item processing
    #
    # @return [Float, 0] the statistical variance of the given data set
    #   or zero if the data set is empty
    def probability_variance(data, opts={}, &block)
      return 0 if data.nil? || data.empty?
      from_probability = data.respond_to? :keys

      data = probability(data, &block) unless from_probability
      mean = data.reduce(0.0) do |n, key, value|
        key, value = key if key.is_a? Array
        key = yield(key) if from_probability && block_given?
        n + (key * value)
      end

      variance = data.reduce(0.0) do |n, key, value|
        key, value = key if key.is_a? Array
        key = yield(key) if from_probability && block_given?
        n + (value * ((key - mean) ** 2))
      end

      return variance
    end

    alias :pmf_variance :probability_variance
  end
end
