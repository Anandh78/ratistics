module Ratistics

  module Collection
    extend self

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
      if args.size == 1
        if index.is_a? Range
          slice_with_range(data, index)
        else
          slice_with_index(data, index)
        end
      elsif args.size == 2
        slice_with_length(data, index, length)
      else
        raise ArgumentError.new("wrong number of arguments (#{args.size} for 2..3)")
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
      return nil if range.first < 0 || range.first >= data.size
      last = [range.last, data.size-1].min
      range = Range.new(range.first, last)
      slice = []
      range.each do |index|
        slice << data[index]
      end
      return slice
    end

  end
end
