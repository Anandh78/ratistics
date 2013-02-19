module Ratistics

  module Collection
    extend self

    # Collect sample data from a generic collection, processing each item
    # with a block when given. Returns an array of the items from +data+
    # in order.
    # 
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to be collected
    # @param [Block] block optional block for per-item processing
    #
    # @return [Array] an array of zero or more items
    def collect(data, opts={}, &block)
      return [] if data.nil?
      sample = []
      data.each do |datum|
        datum = yield(datum) if block_given?
        sample << datum
      end
      return sample
    end

    # Collect sample data from a generic collection, processing each item
    # with a block when given. Returns an array of arrays. Each element
    # is a two-element array where the first element is the index within
    # the outer array and the second element is the corresponding item
    # from within +data+. The elements in the returned array are in the
    # same order as the original +data+ collection.
    #
    # @example
    #   sample = [5, 1, 9, 3, 14, 9, 7]
    #   Collection.catalog(sample) #=> [[0, 5], [1, 1], [2, 9], [3, 3], [4, 14], [5, 9], [6, 7]]
    # 
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to be collected
    # @param [Block] block optional block for per-item processing
    #
    # @return [Array] an array of zero or more items
    def catalog(data, opts={}, &block)
      return [] if data.nil?
      sample = []
      index = 0
      data.each do |datum|
        datum = yield(datum) if block_given?
        sample << [index, datum]
        index = index + 1
      end
      return sample
    end

    alias :catalogue :catalog

    # Scan a collection and determine if the elements are all in
    # ascending order. Returns true for an empty set and false for
    # a nil sample.
    # 
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to search
    # @param [Hash] opts search options
    # @param [Block] block optional block for per-item processing
    #
    # @return [true, false] if the data set is in ascending order
    def ascending?(data, opts={}, &block)
      return false if data.nil?
      (data.size-1).times do |i|
        if block_given?
          return false if yield(data[i]) > yield(data[i+1])
        else
          return false if data[i] > data[i+1]
        end
      end
      return true
    end

    # Scan a collection and determine if the elements are all in
    # descending order. Returns true for an empty set and false for
    # a nil sample.
    # 
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to search
    # @param [Hash] opts search options
    # @param [Block] block optional block for per-item processing
    #
    # @return [true, false] if the data set is in descending order
    def descending?(data, opts={}, &block)
      return false if data.nil?
      (data.size-1).times do |i|
        if block_given?
          return false if yield(data[i]) < yield(data[i+1])
        else
          return false if data[i] < data[i+1]
        end
      end
      return true
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
