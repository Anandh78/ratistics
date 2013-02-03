require 'ratistics/functions'

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
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to compute the mean of
    # @param [Block] block optional block for per-item processing
    #
    # @return [Float, 0] the statistical mean of the given data set
    #   or zero if the data set is empty
    def mean(data, opts={}, &block)
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

    # Calculates a truncated statistical mean.
    #
    # The truncation value represents the number of high and low
    # outliers to remove from the sample before calculating the
    # mean. It is a percentage of the sample size. This percent
    # will be removed from both the high end and the low end of
    # the sample. Therefore the total sample size will be reduced
    # by double the truncation value. A truncation value of 50%
    # or greater will cause an exception to be raised. The
    # truncation value can be expressed as a percentage (10.0)
    # or a decimal (0.10). When an exact truncation is not
    # possible (with one-tenth of one percent precision) the mean
    # will be calculated using interpolation.
    #
    # If the truncation value is nil then only the highest and
    # lowest individual values will be dropped. A sample size of
    # less that three with a nil truncation value will always
    # return zero.
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
    # @param [Float] truncation the percentage value of truncation of
    #   both high and low outliers
    # @param [Boolean] sorted indicates of the list is already sorted
    # @param [Block] block optional block for per-item processing
    #
    # @return [Float, 0] the statistical mean of the given data set
    #   or zero if the data set is empty
    def truncated_mean(data, truncation=nil, opts={}, &block)
      return 0 if data.nil? || data.empty?
      data = data.sort unless block_given? || opts[:sorted] == true

      if truncation.nil?
        if data.count >= 3
          mean = Average.mean(data.slice(1..data.count-2))
        else
          mean = 0
        end
      else
        truncation = truncation * 100.0 if truncation < 1.0
        raise ArgumentError if truncation >= 50.0

        interval = 100.0 / data.count
        steps = truncation / interval

        if Functions.delta(steps, steps.to_i) < 0.1
          
          # exact truncation
          index, length = steps.floor, data.count-(steps.floor * 2)
          if data.respond_to? :slice
            slice = data.slice(index, length)
          else
            slice = Functions.slice(data, index, length)
          end
          mean = Average.mean(slice, &block)

        else

          # interpolation truncation
          index1, length1 = steps.floor, data.count-(steps.floor * 2)
          index2, length2 = steps.ceil, data.count-(steps.ceil * 2)

          if data.respond_to? :slice
            slice1 = data.slice(index1, length1)
            slice2 = data.slice(index2, length2)
          else
            slice1 = Functions.slice(data, index1, length2)
            slice2 = Functions.slice(data, index1, length2)
          end

          m1 = Average.mean(slice1, &block)
          m2 = Average.mean(slice2, &block)
          mean = mean([m1, m2])
        end
      end

      return mean
    end

    alias :trimmed_mean :truncated_mean

    # Calculates the statistical midrange.
    #
    # Will sort the data set using natural sort order unless
    # the #sorted argument is true or a block is given.
    #
    # When a block is given the block will be applied to every
    # element in the data set. Using a block in this way allows
    # probability to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # @note
    #   Unlike other functions with a *sorted* parameter, #midrange
    #   does not actually sort the data set. Instead it scans it for
    #   the minimum and maximum elements. Therefore this function
    #   will work on an unsorted collection even when a block is
    #   given. When the data is sorted, however, the scan will be
    #   skipped.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to compute the midrange of
    # @param [Boolean] sorted indicates of the list is already sorted
    # @param [Block] block optional block for per-item processing
    #
    # @return [Float, 0] the statistical midrange of the given data set
    #   or zero if the data set is empty
    def midrange(data, opts={}, &block)
      return 0 if data.nil? || data.empty?

      if opts[:sorted] == true
        min = block_given? ? yield(data.first) : data.first
        max = block_given? ? yield(data.last) : data.last
      else
        min, max = Functions.minmax(data, &block)
      end

      return Average.mean([min, max])
    end

    alias :midextreme :midrange

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
    def median(data, opts={}, &block)
      return 0 if data.nil? || data.empty?
      data = data.sort unless block_given? || opts[:sorted] == true

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
    def mode(data, opts={}, &block)
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

      modes = modes.sort_by{|key, value| value * -1 }

      modes = modes.reduce([]) do |memo, mode|
        break(memo) if mode[1] < modes[0][1]
        memo << mode[0]
      end

      return modes
    end
  end
end
