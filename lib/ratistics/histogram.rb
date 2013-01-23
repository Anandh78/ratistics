module Ratistics

  # Various histogram computation functions.
  module Histogram
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
    def frequency(data, &block)
      return nil if data.nil? || data.empty?

      freq = data.reduce({}) do |memo, datum|
        datum = yield(datum) if block_given?
        memo[datum] = memo[datum].to_i + 1
        memo
      end

      return freq
    end

    # Calculates the statistical probability.
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
    # @param [Enumerable] data the data set to compute the probability of
    # @param [Block] block optional block for per-item processing
    #
    # @return [Hash, nil] the statistical probability of the given data set
    #   or nil if the data set is empty
    def probability(data, &block)
      return nil if data.nil? || data.empty?

      freq = frequency(data, &block)
      count = data.count

      prob = freq.reduce({}) do |memo, datum|
        memo[datum[0]] = datum[1].to_f / count.to_f
        memo
      end

      return prob
    end
  end
end
