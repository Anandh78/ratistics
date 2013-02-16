require 'ratistics/average'
require 'ratistics/collection'
require 'ratistics/math'
require 'ratistics/probability'
require 'ratistics/search'

module Ratistics

  # From Wikipedia:
  # 
  #    In statistics, a percentile (or centile) is the value of a variable below
  #    which a certain percent of observations fall. For example, the 20th percentile
  #    is the value (or score) below which 20 percent of the observations may be found.
  #    The term percentile and the related term percentile rank are often used in the
  #    reporting of scores from norm-referenced tests. For example, if a score is in
  #    the 86th percentile, it is higher than 85% of the other scores.
  #
  #    The 25th percentile is also known as the first quartile (Q1), the 50th percentile
  #    as the median or second quartile (Q2), and the 75th percentile as the third
  #    quartile (Q3).
  #
  #    ...
  #
  #    The percentile rank of a score is the percentage of scores in its frequency
  #    distribution that are the same or lower than it. For example, a test score that
  #    is greater than 75% of the scores of people taking the test is said to be at the
  #    75th percentile rank.
  #    
  #    Percentile ranks are commonly used to clarify the interpretation of scores on
  #    standardized tests. For the test theory, the percentile rank of a raw score is
  #    interpreted as the percentages of examinees in the norm group who scored below
  #    the score of interest. 
  #
  # Unfortunately, statisticians do not agree on one single formula for caclulating
  # percentiles and percentile ranks. This module implements several of the most
  # common methods. Each calculation is internally consistent. Results for all data
  # sets will be consistent according to the rules of any given functions. Results
  # with a single data set may be inconsistent across different functions. This is
  # the nature of percentiles and percentile ranks.
  #
  # @see http://en.wikipedia.org/wiki/Percentile
  # @see http://en.wikipedia.org/wiki/Percentile_rank
  # @see http://en.wikipedia.org/wiki/Quantile
  module Rank
    extend self

    # Calculate the set of percentile ranks for every element in the sample.
    #
    #   P = 100 * ( i - 0.5 ) / N
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
    #
    # @see http://en.wikipedia.org/wiki/Percentile_rank
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

    # Calculate the percent rank for the given index within the sorted
    # data set. This is the same calculation performed by the {#ranks}
    # method. Where that method calculates the percentile for every
    # element in the data set, this gives just the percentile of the
    # value at the given index.
    #
    #   R = ( 100 / N ) * ( i - 0.5 )
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
    # @see #ranks
    #
    # @return [Numeric] percentile of the given index
    #
    # @see http://en.wikipedia.org/wiki/Percentile_rank
    def percent_rank(data, index, opts={})
      return nil if data.nil? || data.empty?
      return nil if index <= 0 || index > data.size
      data = data.sort unless block_given? || opts[:sorted] == true

      rank = (100.0 / data.size) * (index.to_f - 0.5)
      return rank
    end

    alias :percentile_rank :percent_rank

    # Calculate the percentile of the given value.
    # 
    #   P = L + ( 0.5 * S ) / N 
    #
    #   Where,
    #     L = Number of below rank, 
    #     S = Number of same rank,
    #     N = Total numbers.
    #
    # Will sort the data set using natural sort order unless
    # the :sorted option is true. Will calculate the
    # {Probability#frequency} of the sample first unless the frequency
    # distribution is passed as the :frequency option.
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
    # @param [Float] value the value to calculate the percentile of
    # @param [Hash] opts computation options
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [true, false] :sorted indicates of the data is already sorted
    # @option opts [true, false] :ranked indicates of the data is already ranked
    #   by the {#ranks} function
    #
    # @return [Numeric] approximate percentile of the given value within the sample
    #
    # @see Probability#frequency
    # @see http://easycalculation.com/statistics/percentile-rank.php
    def percentile(data, value, opts={}, &block)
      return nil if data.nil? || data.empty?
      data = data.sort unless block_given? || opts[:sorted] == true

      frequency = opts[:frequency] || Probability.frequency(data, &block)
      ranks = frequency.keys.sort
      l, s = Search.binary_search(ranks, value)

      return 0 if l.nil?
      return 100 if s.nil?

      l = Math.summation(ranks, :upper => s-1){|item| frequency[item]}
      s = frequency[value].to_i
      n = data.size

      return ((l + (0.5 * s)) / n.to_f) * 100.0
    end

    alias :centile :percentile

    # Calculate the percentile rank nearest to the given percentile.
    #
    #   Ordinal:
    #     n = ( P / 100 * N ) + 0.5 
    #
    #   NIST Primary:
    #     n = ( P / 100 ) * ( N + 1 )
    #
    #   NIST ALternate:
    #     n = ( ( P / 100 ) * ( N - 1 ) ) + 1 
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
    #
    # @see Math#ordinal_rank
    # @see Math#nist_primary_rank
    # @see Math#nist_alternate_rank
    # @see http://en.wikipedia.org/wiki/Percentile
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
    #   P = ( 100 / N ) * ( n - 0.5 )
    #
    #   v = vk + ( N * ( P - pk ) / 100.0 * ( vk1 - vk ) ) 
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
    # @option opts [true, false] :ranked indicates of the data is already ranked
    #   by the {#ranks} function
    #
    # @return [Numeric] value at the rank nearest to the given percentile
    #
    # @see #ranks
    #
    # @see http://en.wikipedia.org/wiki/Percentile
    def linear_rank(data, percentile, opts={}, &block)
      return nil if data.nil? || data.empty?

      if opts[:ranked] == true
        ranks = data
      else
        ranks = Rank.ranks(data, opts.merge(:flatten => true), &block)
      end

      opts = { :sorted => true, :delta => opts[:delta] }
      indexes = Search.binary_search(ranks, percentile, opts){|rank| rank.last}
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

    alias :linear_interpolation_rank :linear_rank

    # Calculate the value representing the upper-bound of the first
    # quartile (percentile) of a data sample. This is the equivalent
    # of the median of the subset of the sample from the lower bound to
    # the sample-median.
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
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [true, false] :sorted indicates of the data is already sorted
    #
    # @return [Numeric] value at the rank nearest to the given percentile
    #
    # @see {Average#median}
    # @see http://en.wikipedia.org/wiki/Quantile
    def first_quartile(data, opts={}, &block)
      return nil if data.nil? || data.empty?
      midpoint = (data.size / 2.0).floor - 1
      return Average.median(Collection.slice(data, (0..midpoint)), opts, &block)
    end

    alias :lower_quartile :first_quartile

    # Calculate the value representing the upper-bound of the second
    # quartile (percentile) of a data sample. This is the equivalent
    # of the sample median.
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
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [true, false] :sorted indicates of the data is already sorted
    #
    # @return [Numeric] value at the rank nearest to the given percentile
    #
    # @see {Average#median}
    # @see http://en.wikipedia.org/wiki/Quantile
    def second_quartile(data, opts={}, &block)
      return nil if data.nil? || data.empty?
      return Average.median(data, opts, &block)
    end

    # Calculate the value representing the upper-bound of the third
    # quartile (percentile) of a data sample. This is the equivalent
    # of the median of the subset of the sample from the sample-median
    # to the upper bound.
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
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [true, false] :sorted indicates of the data is already sorted
    #
    # @return [Numeric] value at the rank nearest to the given percentile
    #
    # @see {Average#median}
    # @see http://en.wikipedia.org/wiki/Quantile
    def third_quartile(data, opts={}, &block)
      return nil if data.nil? || data.empty?
      midpoint = (data.size / 2.0).ceil
      high = data.size - 1
      return Average.median(Collection.slice(data, (midpoint..high)), opts, &block)
    end

    alias :upper_quartile :third_quartile

  end
end
