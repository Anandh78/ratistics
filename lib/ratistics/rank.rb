require 'ratistics/collection'
require 'ratistics/math'

module Ratistics

  module Rank
    extend self

    # Calculate the set of percentile ranks for every element in the sample.
    #
    # Will sort the data set using natural sort order unless
    # the :sorted option is true or a block is given. When the :flatten
    # option is true duplicate values will be removed from the sample and
    # only the highest percentile for that value will be returned.
    #
    # When a block is given the block will be applied to every
    # element in the data set. Using a block in this way allows
    # probability to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # The return value is an array of arrays. Each element in the outer
    # array represents one value in the sample. Each value will be a
    # two-element array where the first value is the element itself and
    # the second element will be the percentile.
    #
    # @example
    #   [[1, 7.142857142857143],
    #    [3, 21.428571428571427],
    #    [5, 35.714285714285715],
    #    [7, 50.0],
    #    [9, 64.28571428571429],
    #    [9, 78.57142857142857],
    #    [14, 92.85714285714286]]
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to compute the percentiles for
    # @param [Hash] opts computation options
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [true, false] :sorted indicates of the data is already sorted
    # @option opts [String] :flatten remove duplicate data values
    #
    # @return [Array] set of values and percentiles
    def ranks(data, opts={}, &block)
      return [] if data.nil? || data.empty?
      data = data.sort unless block_given? || opts[:sorted] == true

      ranks = []

      data.size.times do |index|

        p = 100.0 * ((index+1).to_f - 0.5) / data.size.to_f

        item = block_given? ? yield(data[index]) : data[index]
        if opts[:flatten] == true && index > 0 && ranks.last[0] == item
          ranks.pop
        end

        ranks << [item, p]
      end

      return ranks
    end

    alias :percentiles :ranks
    alias :centiles :ranks

    # Calculate the percent rank for the given index within the sorted
    # data set.
    #
    # Will sort the data set using natural sort order unless
    # the :sorted option is true.
    #
    # @note
    #   Statistical indexes start at one (1) where the first element in
    #   the data set is one (1). Unlike Ruby which indexes collections
    #   beginning with zero (0).
    #
    # @param [Enumerable] data the data set against which percentile is computed
    # @param [Integer] index the index within the collection to calculate
    #   the percentile of
    # @param [Hash] opts computation options
    #
    # @option opts [true, false] :sorted indicates of the data is already sorted
    #
    # @return [Numeric] percentile of the given index
    def percent_rank(data, index, opts={})
      return nil if data.nil? || data.empty?
      return nil if index <= 0 || index > data.size
      data = data.sort unless block_given? || opts[:sorted] == true

      rank = (100.0 / data.size) * (index.to_f - 0.5)
      return rank
    end

    # Return the percentile rank nearest to the given percentile.
    #
    # Will sort the data set using natural sort order unless
    # the :sorted option is true or a block is given.
    #
    # When a block is given the block will be applied to every
    # element in the data set. Using a block in this way allows
    # probability to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set against which percentile is computed
    # @param [Float] percentile the percentile to find the nearest rank of
    # @param [Hash] opts computation options
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [true, false] :sorted indicates of the data is already sorted
    # @option opts [Symbol] :rank which method to use to calculate the percentile
    #   rank: :ordinal, :nist_primary, :nist_alternate (default: ordinal)
    #
    # @return [Numeric] value at the rank nearest to the given percentile
    def nearest_rank(data, percentile, opts={}, &block)
      return nil if data.nil? || data.empty?
      data = data.sort unless block_given? || opts[:sorted] == true
      return data.first if percentile == 0
      return data.last if percentile == 100

      calc = opts[:rank] || :ordinal
      index = Math.send("#{calc}_rank", percentile, data.size).round

      if block_given?
        rank = yield(data[index-1])
      else
        rank = data[index-1]
      end

      return rank
    end

    # Return the percentile rank nearest to the given percentile using
    # linear interpolation between closest ranks 
    # 
    # Will sort the data set using natural sort order unless
    # the :sorted option is true or a block is given.
    #
    # When a block is given the block will be applied to every
    # element in the data set. Using a block in this way allows
    # probability to be computed against a specific field in a
    # data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set against which percentile is computed
    # @param [Float] percentile the percentile to find the linear interpolation of
    # @param [Hash] opts computation options
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [true, false] :sorted indicates of the data is already sorted
    #
    # @return [Numeric] value at the rank nearest to the given percentile
    def linear_rank(data, percentile, opts={}, &block)
      return nil if data.nil? || data.empty?
      ranks = Rank.ranks(data, opts.merge(:flatten => true), &block)

      opts = { :sorted => true, :delta => opts[:delta] }
      indexes = Collection.binary_search(ranks, percentile, opts){|rank| rank.last}
      return ranks.last.first if indexes.first == ranks.size-1
      return ranks.first.first if indexes.last == 0
      return ranks[indexes.first].first if indexes.first == indexes.last

      vk = ranks[indexes.first].first
      n = ranks.size
      p = percentile
      pk = ranks[indexes.first].last
      vk1 = ranks[indexes.last].first
      rank = vk + (n * (p - pk) / 100.0 * (vk1 - vk)) 

      return rank
    end

    alias :percentile :linear_rank
    alias :centile :linear_rank

    #def weighted_percentile(data, percentile, opts={}, &block)
    #end

    #def percentile?
    #end

    #alias :centile? :percentile?

    ## The percentage of scores in the frequency distribution that are the same or lower
    #def percentile_rank(data, value, sorted=false, opts={}, &block)
    #alias :centile_rank :percentile_rank

    #def percentile_rank?(data, value, percentile, sorted=false, opts={}, &block) 
    #alias :centile_rank? :percentile_rank?

    #def lower_quartile
    #def upper_quartile
    #def first_quartile
    #def second_quartile
    #def third_quartile



  end
end
