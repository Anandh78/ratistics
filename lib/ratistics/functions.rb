module Ratistics

  module Functions
    extend self

    # Compute the difference (delta) between two values.
    # 
    # When a block is given the block will be applied to both
    # arguments. Using a block in this way allows the
    # difference to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Object] v1 the first value
    # @param [Object] v2 the second value
    # @param [Block] block optional block for per-item processing
    #
    # @return [Float] positive value representing the difference
    #   between the two parameters
    def delta(v1, v2, &block)
      if block_given?
        v1 = yield(v1)
        v2 = yield(v2)
      end
      return (v1 - v2).abs
    end

    # Compute the relative risk (risk ratio) between two values.
    # 
    # When a block is given the block will be applied to both
    # arguments. Using a block in this way allows the
    # difference to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Object] v1 the first value
    # @param [Object] v2 the second value
    # @param [Block] block optional block for per-item processing
    #
    # @return [Float] positive value representing the relative risk
    #   between the two parameters
    def relative_risk(v1, v2, &block)
      if block_given?
        v1 = yield(v1)
        v2 = yield(v2)
      end
      return v1.to_f / v2.to_f
    end

    alias :risk_ratio :relative_risk

    # Returns the minimum value of in the given data set. If a block
    # is provided it will applied against every element in the collection
    # before comparison. In this case the return value will be the
    # value obtained by applying the block to the minimum element,
    # not the element itself.
    #
    # @example
    #   sample = [
    #     {:count => 18},
    #     {:count => 13},
    #     {:count => 21},
    #   ]
    #
    #   Functions.min([18, 13, 21]) #=> 13
    #   Functions.min(sample){|item| item[:count] } #=> 13
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set being searched
    # @param [Block] block optional block for per-item processing
    #
    # @return [Object] the minimum value
    def min(data, &block)
      return nil if data.nil? || data.empty?

      if data.respond_to?(:min)
        min = block_given? ? yield(data.min_by(&block)) : data.min
      else
        min = block_given? ? yield(data.first) : data.first
        data.each do |datum|
          datum = yield(datum) if block_given?
          min = datum if datum < min
        end
      end

      return min
    end

    # Returns the maximum value of in the given data set. If a block
    # is provided it will applied against every element in the collection
    # before comparison. In this case the return value will be the
    # value obtained by applying the block to the maximum element,
    # not the element itself.
    #
    # @example
    #   sample = [
    #     {:count => 18},
    #     {:count => 13},
    #     {:count => 21},
    #   ]
    #
    #   Functions.max([18, 13, 21]) #=> 21
    #   Functions.max(sample){|item| item[:count] } #=> 21
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set being searched
    # @param [Block] block optional block for per-item processing
    #
    # @return [Object] the maximum value
    def max(data, &block)
      return nil if data.nil? || data.empty?

      if data.respond_to?(:max)
        max = block_given? ? yield(data.max_by(&block)) : data.max
      else
        max = block_given? ? yield(data.first) : data.first
        data.each do |datum|
          datum = yield(datum) if block_given?
          max = datum if datum > max
        end
      end

      return max
    end

    # Returns the minimum and maximum values of in the given data set.
    # If a block is provided it will applied against every element in
    # the collection before comparison. In this case the return values
    # will be the values obtained by applying the block to the minimum
    # and maximum elements, not the elements themselves.
    #
    # @example
    #   sample = [
    #     {:count => 18},
    #     {:count => 13},
    #     {:count => 21},
    #   ]
    #
    #   Functions.minmax([18, 13, 21]) #=> [13, 21]
    #   Functions.minmax(sample){|item| item[:count] } #=> [13, 21]
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set being searched
    # @param [Block] block optional block for per-item processing
    #
    # @return [Array] the minimum and maximum values
    def minmax(data, &block)
      return [nil, nil] if data.nil? || data.empty?

      if data.respond_to?(:minmax)
        minmax = block_given? ? data.minmax_by(&block) : data.minmax
        minmax = [yield(minmax[0]), yield(minmax[1])] if block_given?
      else
        min = max = (block_given? ? yield(data.first) : data.first)
        data.each do |datum|
          datum = yield(datum) if block_given?
          min = datum if datum < min
          max = datum if datum > max
        end
        minmax = [min, max]
      end

      return minmax
    end

    # Override of #slice from Ruby Array. Provides a consistent interface
    # to slice data structures that do not have a native #slice method.
    #
    # Returns the element at index, or returns a subarray starting at
    # start and continuing for length elements, or returns a subarray
    # specified by range. Negative indices count backward from the end
    # of the array (-1 is the last element). Returns nil if the index
    # (or starting index) is out of range.
    #
    # @overload slice(data, index)
    #   @param [Enumerable] data the collection to slice
    #   @param [Integer] index the index to slice
    #
    # @overload slice(data, start, length)
    #   @param [Enumerable] data the collection to slice
    #   @param [Integer] start the start index for the slice
    #   @param [Integer] length the length of the slice
    #
    # @overload slice(data, range)
    #   @param [Enumerable] data the collection to slice
    #   @param [Range] range range of indices to include in the slice
    #
    # @return [Array] the slice
    def slice(data, *args)
      index = args[0]
      length = args[1]
      if args.count == 1
        if index.is_a? Range
          slice_with_range(data, index)
        else
          slice_with_index(data, index)
        end
      elsif args.count == 2
        slice_with_length(data, index, length)
      else
        raise ArgumentError.new("wrong number of arguments (#{args.count} for 2..3)")
      end
    end

    # :nodoc:
    # @private
    def slice_with_index(data, index)
      return data[index]
    end

    # :nodoc:
    # @private
    def slice_with_length(data, start, length)
      range = Range.new(start, start+length-1)
      slice_with_range(data, range)
    end

    # :nodoc:
    # @private
    def slice_with_range(data, range)
      return nil if range.first < 0 || range.first >= data.count
      last = [range.last, data.count-1].min
      range = Range.new(range.first, last)
      slice = []
      range.each do |index|
        slice << data[index]
      end
      return slice
    end
  end
end
