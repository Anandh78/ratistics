module Ratistics

  # Various average computation functions.
  module Average
    extend self

    # Calculates the statistical mean.
    #
    # When no block is given every element in the data set will be
    # cast to a float before computation. When a block is given
    # the block will be applied to every element in the data set
    # and the result of the block will be cast to a float. Using
    # a block in this way allows the mean to be computed against
    # a specific field in a data set of hashes or objects.
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
      return 0 if data.empty?
      total = 0.0

      data.each do |item|
        if block_given?
          total = total + yield(item).to_f
        else
          total = total + item.to_f
        end
      end

      return total / data.count.to_f
    end

    alias :avg :mean
    alias :average :mean

    def median
    end

    def mode
    end

  end
end
