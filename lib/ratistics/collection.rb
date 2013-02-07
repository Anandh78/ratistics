module Ratistics

  module Collection
    extend self

    # Sorts the collection using the insertion sort algorithm.
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
    # @return [Array] the sorted collection
    def insertion_sort!(data, opts={}, &block)
      return data if data.nil? || data.size <= 1

      (1..(data.size-1)).each do |j|

        key = block_given? ? yield(data[j]) : data[j]
        value = data[j]
        i = j - 1
        current = block_given? ? yield(data[i]) : data[i]

        while i >= 0 && current > key
          data[i+1] = data[i]
          i = i - 1
          current = block_given? ? yield(data[i]) : data[i]
        end

        data[i+1] = value
      end

      return data
    end

    # Conduct a binary search against the sorted collection and return
    # a pair of indexes indicating the result of the search. The
    # indexes will be returned as a two-element array.
    #
    # The default behavior is to search the entire collections. The
    # options hash can be used to provide optional low and high indexes
    # (:imin and :imax). If either :imin or :imax is out of range the
    # natural collection boundary will be used.
    # 
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # When the key is found both returned indexes will be the index of
    # the item. When the key is not found but the value is within the
    # range of value in the data set the returned indexes will be
    # immediately above and below where the key would reside. When
    # the key is below the lowest value in the search range the result
    # will be nil and the lowest index. When the key is higher than the
    # highest value in the search range the result will be the highest
    # index and nil. 
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to search
    # @param [Hash] opts search options
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [Integer] :imin minimum index to search
    # @option opts [Integer] :imax maximum index to search
    #
    # @return [Array] pair of indexes (see above) or nil when the collection
    #   is empty or nil
    def binary_search(data, key, opts={}, &block)
      return nil if data.nil? || data.empty?

      imin = [opts[:imin].to_i, 0].max
      imax = opts[:imax].nil? ? data.size-1 : [opts[:imax], data.size-1].min
      return nil if imin > imax

      if block_given?
        min, max = yield(data[imin]), yield(data[imax])
      else
        min, max = data[imin], data[imax]
      end
      return [nil, imin] if key < min
      return [imin, imin] if key == min
      return [imax, nil] if key > max
      return [imax, imax] if key == max

      while (imax >= imin)
        imid = (imin + imax) / 2
        current = data[imid]
        current = yield(current) if block_given?
        if current < key
          imin = imid + 1
        elsif current > key
          imax = imid - 1
        else
          imin = imax = imid
          break
        end
      end

      return imax, imin
    end

    alias :bsearch :binary_search
    alias :half_interval_search :binary_search

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
    # @param [true, false] if the data set is in ascending order
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
    # @param [true, false] if the data set is in descending order
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
