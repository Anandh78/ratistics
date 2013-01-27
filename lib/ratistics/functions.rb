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
    # For a block {|item| ... }
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
    # For a block {|item| ... }
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

  end
end
