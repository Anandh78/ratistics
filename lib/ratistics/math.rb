module Ratistics

  module Math
    extend self

    # Compute the difference (delta) between two values.
    # 
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
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
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
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
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @example
    #   sample = [
    #     {:count => 18},
    #     {:count => 13},
    #     {:count => 21},
    #   ]
    #
    #   Math.min([18, 13, 21]) #=> 13
    #   Math.min(sample){|item| item[:count] } #=> 13
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
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @example
    #   sample = [
    #     {:count => 18},
    #     {:count => 13},
    #     {:count => 21},
    #   ]
    #
    #   Math.max([18, 13, 21]) #=> 21
    #   Math.max(sample){|item| item[:count] } #=> 21
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
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @example
    #   sample = [
    #     {:count => 18},
    #     {:count => 13},
    #     {:count => 21},
    #   ]
    #
    #   Math.minmax([18, 13, 21]) #=> [13, 21]
    #   Math.minmax(sample){|item| item[:count] } #=> [13, 21]
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

    # Calculate percentile rank using the ordinal method
    #
    #   N = ( P / 100 * N ) + 0.5 
    #
    # @param [Float] percentile percentile value (0 < P < 100)
    # @param [Integer] size the size of the data sample (N)
    #
    # @return [Float] the corresponding rank
    def ordinal_rank(percentile, size)
      # n = P / 100 * N + 1/2
      ((percentile / 100.0 * size) + 0.5)
    end

    # Calculate percentile rank using the NIST primary method
    #
    #   n = ( P / 100 ) * ( N + 1 )
    #
    # @param [Float] percentile percentile value (0 < P < 100)
    # @param [Integer] size the size of the data sample (N)
    #
    # @return [Float] the corresponding rank
    def nist_primary_rank(percentile, size)
      # n = (P / 100) * (N + 1)
      ((percentile / 100.0) * (size + 1))
    end

    # Calculate percentile rank using the NIST alternate method
    #
    #   n = ( ( P / 100 ) * ( N - 1 ) ) + 1 
    #
    # @param [Float] percentile percentile value (0 < P < 100)
    # @param [Integer] size the size of the data sample (N)
    #
    # @return [Float] the corresponding rank
    def nist_alternate_rank(percentile, size)
      # n = ((P / 100) * (N - 1)) + 1
      (((percentile / 100.0) * (size - 1)) + 1)
    end

    # Performs a mathematical summation operation on the given data set.
    # Returns zero (the identity for addition) when given an empty data
    # set or invalid upper/lower bounds (degenerate case).
    # 
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set being searched
    # @param [Block] block optional block for per-item processing
    #
    # @return [Numeric] the result of the summation operation
    def summation(data, opts={}, &block)
      return 0 if data.nil? || data.empty?

      lower = opts[:lower] || 0
      upper = opts[:upper] || data.size-1
      
      return 0 if lower < 0 || upper >= data.size || lower > upper

      sum = 0
      (lower..upper).each do |i|
        if block_given?
          sum += yield(data[i])
        else
          sum += data[i]
        end
      end

      return sum
    end

    alias :sum :summation

  end
end
