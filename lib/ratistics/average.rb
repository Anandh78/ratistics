module Ratistics

  # Various average computation functions.
  module Average
    extend self

    # Calculates the statistical mean.
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
    # @param [Enumerable] data the data set to compute the mean of
    # @param [Block] block optional block for per-item processing
    #
    # @return [Float, 0] the statistical mean of the given data set
    #   or zero if the data set is empty
    def mean(data, &block)
      return 0 if data.nil? || data.empty?
      total = 0.0

      data.each do |item|
        item = yield(item) if block_given?
        total = total + item.to_f
      end

      return total / data.count.to_f
    end

    alias :avg :mean
    alias :average :mean

    def delta(v1, v2)
      return (v1 - v2).abs
    end

    def truncated_mean(data, truncation, sorted=false, &block)
      return 0 if data.nil? || data.empty?
      data = data.sort unless block_given? || sorted

      truncation = truncation * 100.0 if truncation < 1.0
      raise ArgumentError if truncation >= 50.0

      interval = 100.0 / data.count
      steps = truncation / interval

      if delta(steps, steps.to_i) < 0.1
        # exact truncation
        mean = Average.mean(data.slice(steps.floor..(data.count-steps.floor-1)), &block)
      else
        # interpolation truncation
        m1 = Average.mean(data.slice(steps.floor..(data.count-steps.floor-1)), &block)
        m2 = mean(data.slice(steps.ceil..(data.count-steps.ceil-1)), &block)
        mean = mean([m1, m2])
      end

      return mean
    end

    # Calculates the statistical median.
    #
    # Will sort the data set using natural sort order unless
    # the #sorted argument is true or a block is given.
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
    # @param [Enumerable] data the data set to compute the median of
    # @param [Boolean] sorted indicates of the list is already sorted
    # @param [Block] block optional block for per-item processing
    #
    # @return [Float, 0] the statistical median of the given data set
    #   or zero if the data set is empty
    def median(data, sorted=false, &block)
      return 0 if data.nil? || data.empty?
      data = data.sort unless block_given? || sorted

      index = data.count / 2
      if data.count % 2 == 0 #even

        if block_given?
          median = (yield(data[index-1]) + yield(data[index])) / 2.0
        else
          median = (data[index-1] + data[index]) / 2.0
        end

      else #odd

        if block_given?
          median = yield(data[index])
        else
          median = data[index]
        end
      end

      return median
    end

    # Calculates the statistical modes.
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
    # @param [Enumerable] data the data set to compute the median of
    # @param [Block] block optional block for per-item processing
    #
    # @return [Array] An array of zero or more values (in no particular
    #   order) indicating the modes of the data set
    def mode(data, &block)
      return [] if data.nil? || data.empty?

      modes = {}

      data.each do |item|

        item = yield(item) if block_given?

        if modes.has_key? item
          modes[item] = modes[item]+1
        else
          modes[item] = 1
        end
      end

      modes = modes.sort_by{|key, value| value * -1  }

      modes = modes.reduce([]) do |memo, mode|
        break(memo) if mode[1] < modes[0][1]
        memo << mode[0]
      end

      return modes
    end
  end
end
