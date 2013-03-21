require 'ratistics/collection'
require 'ratistics/math'
require 'ratistics/sort'

module Ratistics

  # Various probability computation functions.
  module Probability
    extend self

    # Calculates the statistical frequency.
    #
    # When a block is given the block will be applied to every element
    # in the data set. Using a block in this way allows computation against
    # a specific field in a data set of hashes or objects.
    #
    # The return value is a hash where the keys are the data elements
    # from the sample and the values are the corresponding frequencies.
    # When the *:as* option is set to *:array* the return value will
    # be an array of arrays. Each element of the outer array will be
    # a two-element array with the sample value at index 0 and the
    # corresponding frequency at index 1.
    #
    # @example
    #   sample = [13, 18, 13, 14, 13, 16, 14, 21, 13]
    #   Ratistics.frequency(sample) #=> {13=>4, 18=>1, 14=>2, 16=>1, 21=>1}
    #   Ratistics.frequency(sample, :as => :array) #=> [[13, 4], [18, 1], [14, 2], [16, 1], [21, 1]]
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data to perform the calculation against
    # @param [Hash] opts processing options
    #
    # @option opts [Symbol] :as sets the output to :hash/:map or
    #   :array/:catalog/:catalogue (default :hash)
    #
    # @return [Hash, Array, nil] the statistical frequency of the given
    #   data set or nil if the data set is empty
    def frequency(data, opts={})
      return nil if data.nil? || data.empty?

      freq = data.reduce({}) do |memo, datum|
        datum = yield(datum) if block_given?
        memo[datum] = memo[datum].to_i + 1
        memo
      end

      if (opts[:as] == :array || opts[:as] == :catalog || opts[:as] == :catalogue)
        freq = Collection.catalog_hash(freq)
      end

      return freq
    end

    # Calculates the statistical probability.
    #
    # When a block is given the block will be applied to every element
    # in the data set. Using a block in this way allows computation against
    # a specific field in a data set of hashes or objects.
    #
    # @example
    #   sample = [13, 18, 13, 14, 13, 16, 14, 21, 13]
    #   Ratistics.probability(sample) #=> {13=>0.4444444444444444, 18=>0.1111111111111111, 14=>0.2222222222222222, 16=>0.1111111111111111, 21=>0.1111111111111111}
    #   Ratistics.probability(sample, :as => :array) #=> [[13, 0.4444444444444444], [18, 0.1111111111111111], [14, 0.2222222222222222], [16, 0.1111111111111111], [21, 0.1111111111111111]]
    #   Ratistics.probability(sample, :as => :catalog) #=> [[13, 0.4444444444444444], [18, 0.1111111111111111], [14, 0.2222222222222222], [16, 0.1111111111111111], [21, 0.1111111111111111]]
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data to perform the calculation against
    # @param [Hash] opts processing options
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [Symbol] :from describes the nature of the data.
    #   :sample indicates *data* is a raw data sample, :frequency
    #   (or :freq) indicates *data* is a frequency distribution
    #   created from the #frequency function. (default :sample)
    #
    # @option opts [Symbol] :as sets the output to :hash or :array
    #   (default :hash)
    #
    # @return [Array, Hash, nil] the statistical probability of the given data set
    #   or nil if the data set is empty
    #
    # @see #frequency
    def probability(data, opts={}, &block)
      return nil if data.nil? || data.empty?
      from_frequency = (opts[:from] == :frequency || opts[:from] == :freq)

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

      if opts[:inc] || opts[:increment] || opts[:incremental]
        base = 0
        prob.keys.sort.each do |key|
          prob[key] = base = prob[key] + base
        end
      end

      if (opts[:as] == :array || opts[:as] == :catalog || opts[:as] == :catalogue)
        prob = Collection.catalog_hash(prob)
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
    # @param [Enumerable] pmf the data to perform the calculation against
    # 
    # @return [Hash] a new, normalized probability distribution.
    def normalize_probability(pmf, opts={})
      total = pmf.values.reduce(0.0){|n, value| n + value} 

      return { pmf.keys.first => 1 } if pmf.count == 1
      return pmf if Math.delta(total, 1.0) < 0.01

      factor = 1.0 / total.to_f
      normalized = pmf.reduce({}) do |memo, pair|
        memo[pair[0]] = pair[1] * factor
        memo
      end
      return normalized
    end

    alias :normalize_pmf :normalize_probability

    # Calculates the statistical mean of a probability distribution.
    # Accepts a block for processing individual items.
    #
    # When a block is given the block will be applied to every element
    # in the data set. Using a block in this way allows computation against
    # a specific field in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data to perform the calculation against
    # @param [Hash] opts processing options
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [Symbol] :from describes the nature of the data.
    #   :sample indicates *data* is a raw data sample, :frequency
    #   (or :freq) indicates *data* is a frequency distribution
    #   created from the #frequency function, and :probability
    #   (or :prob) indicates the data is a probability distribution
    #   created by the #probability function. (default :sample)
    #
    # @return [Float, 0] the statistical mean of the given data set
    #   or zero if the data set is empty
    #
    # @see #frequency
    # @see #probability
    def probability_mean(data, opts={}, &block)
      return 0 if data.nil? || data.empty?
      
      from_probability = (opts[:from] == :probability || opts[:from] == :prob)
      unless from_probability
        data = probability(data, :from => opts[:from], &block)
      end

      mean = data.reduce(0.0) do |n, key, value|
        key, value = key if key.is_a? Array
        key = yield(key) if from_probability and block_given?
        n + (key * value)
      end

      return mean
    end

    alias :pmf_mean :probability_mean
    alias :frequency_mean :probability_mean

    # Calculates the statistical variance of a probability distribution.
    # Accepts a block for processing individual items in a raw data
    # sample (:from => :sample).
    #
    # When a block is given the block will be applied to every element
    # in the data set. Using a block in this way allows computation against
    # a specific field in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data to perform the calculation against
    # @param [Hash] opts processing options
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [Symbol] :from describes the nature of the data.
    #   :sample indicates *data* is a raw data sample, :frequency
    #   (or :freq) indicates *data* is a frequency distribution
    #   created from the #frequency function, and :probability
    #   (or :prob) indicates the data is a probability distribution
    #   created by the #probability function. (default :sample)
    #
    # @return [Float, 0] the statistical variance of the given data set
    #   or zero if the data set is empty
    #
    # @see #probability
    def probability_variance(data, opts={}, &block)
      return 0 if data.nil? || data.empty?

      if opts[:from] == :probability || opts[:from] == :prob
        from_probability = true
      else
        data = probability(data, :from => opts[:from], &block)
        from_probability = false
      end
        
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

    # Calculate the probability that a random variable will be at or below
    # a given value based on the given sample (aka cumulative distribution
    # function, CDF).
    #
    #   0 <= P <= 1
    #
    # Accepts a block for processing individual items in a raw data
    # sample (:from => :sample).
    #
    # When a block is given the block will be applied to every element in
    # the data set. Using a block in this way allows probability to be
    # computed against a specific field in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data to perform the calculation against
    # @param [Hash] opts processing options
    #
    # @option opts [Symbol] :from describes the nature of the data.
    #   :sample (the default) indicates *data* is a raw data sample,
    #   :frequency (or :freq) indicates *data* is a frequency distribution
    #   created from the #frequency function.
    #
    # @return [0, Float, 1] the probability of a random variable being at
    #   or below the given value. Returns zero if the value is lower than
    #   the lowest value in the sample and one if the value is higher than
    #   the highest value in the sample. Returns zero for a nil or empty
    #   sample.
    #
    # @see #frequency
    # @see #cumulative_distribution_function_value
    #
    # @see http://www.cumulativedistributionfunction.com/
    # @see http://en.wikipedia.org/wiki/Cumulative_distribution_function
    def cumulative_distribution_function(data, value, opts={})
      return 0 if data.nil? || data.empty?

      count = 0

      if opts[:from] == :frequency || opts[:from] == :freq
        size = 0
        data.each do |datum, freq|
          datum = yield(datum) if block_given?
          count = count + freq if datum <= value
          size = size + freq
        end
      else
        data.each do |datum|
          datum = yield(datum) if block_given?
          count = count + 1 if datum <= value
        end
        size = data.size
      end

      return 0 if count == 0
      return 1 if count == size
      return count / size.to_f
    end

    alias :cdf :cumulative_distribution_function
    alias :cumulative_distribution :cumulative_distribution_function

    # Inverse of the #cumulative_distribution_function function. For the
    # given data sample, return the highest value for a given probability.
    #
    # Accepts a block for processing individual items in a raw data
    # sample (:from => :sample).
    #
    # When a block is given the block will be applied to every element in
    # the data set. Using a block in this way allows probability to be
    # computed against a specific field in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data to perform the calculation against
    # @param [Hash] opts processing options
    #
    # Will sort the data set using natural sort order unless
    # the :sorted option is true or a block is given.
    #
    # @option opts [true, false] :sorted indicates of the data is already sorted
    #
    # @option opts [Symbol] :from describes the nature of the data.
    #   :sample (the default) indicates *data* is a raw data sample,
    #   :frequency (or :freq) indicates *data* is a frequency distribution
    #   created from the #frequency function.
    #
    # @return [Object] the highest value in the sample for the given probability
    #
    # @see #frequency
    # @see #cumulative_distribution_function
    #
    # @see http://www.cumulativedistributionfunction.com/
    # @see http://en.wikipedia.org/wiki/Cumulative_distribution_function
    def cumulative_distribution_function_value(data, prob, opts={}, &block)
      return nil if data.nil? || data.empty? || prob < 0 || prob > 1

      if (opts[:from].nil? || opts[:from] == :sample) && !(block_given? || opts[:sorted] == true)
        data = data.sort
      end

      if opts[:from].nil? || opts[:from] == :sample
        return (block_given? ? yield(data[0]) : data[0]) if prob == 0
        return (block_given? ? yield(data[-1]) : data[-1]) if prob == 1
      else
        return Math.min(data.keys, &block) if prob == 0
        return Math.max(data.keys, &block) if prob == 1
      end

      if opts[:from] == :freq || opts[:from] == :frequency
        ps = probability(data, :as => :array, :inc => true, :from => :freq, &block)
      else
        ps = probability(data, :as => :array, :inc => true, &block)
      end
      ps = Sort.insertion_sort!(ps){|item| item.first}
      index = Collection.bisect_left(ps, prob){|item| item.last}

      index = index-1 if prob == ps[index-1].first
      return ps[index].first
    end

    alias :cdf_value :cumulative_distribution_function_value
    alias :cumulative_distribution_value :cumulative_distribution_function_value
  end
end
