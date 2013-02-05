require 'ratistics/average'

module Ratistics

  class Aggregates

    # Creates a new Aggregates object
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Objects, Enumerable] data the data set to aggregate
    # @param [Block] block optional block for per-item processing
    def initialize(*args, &block)
      @block = block
      if args.count == 0
        raise ArgumentError.new('wrong number of arguments(0 for 1..*)')
      elsif args.count == 1 && args.first.respond_to?(:each)
        @data = args.first
      else
        @data = args
      end

      @truncated_means = {}
    end

    # Returns the number of elements in the sample. May be zero. 
    #
    # @return the number of elements in the sample
    def length
      @length ||= @data.length
    end

    alias :size :length

    # Returns the number of items in the sample. Returns #length when no
    # arguments are given. If an argument is given, counts the number of
    # items in the sample which are equal to *item*. If a block is given,
    # counts the number of elements yielding a true value. If a block was
    # given at initialization each element is yielded to that block before
    # being counted.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Object] item the (optional) item that is being counted or nil
    #   when counting the entire sample
    # @param [Block] block optional block for per-item processing
    #
    # @return [Integer] the count
    def count(item=nil, &block)
      count = 0

      if ! item.nil?
        @data.each do |datum|
          datum = @block.yield(datum) if @block
          count = count + 1 if datum == item
        end
      elsif block_given?
        @data.each do |datum|
          datum = @block.yield(datum) if @block
          count = count + 1 if yield(datum)
        end
      elsif @data.respond_to? :length
        count = @data.length
      else
        @data.each { count = count + 1 }
      end

      return count
    end

    # Calculates the statistical mean.
    #
    # {Average#mean}
    def mean
      @mean ||= Average.mean(@data, &@block)
    end

    alias :avg :mean
    alias :average :mean

    # Calculates a truncated statistical mean.
    #
    # {Average#truncated_mean}
    def truncated_mean(truncation=nil)
      @truncated_means[truncation] ||= Average.truncated_mean(@data, truncation, &@block)
    end

    alias :trimmed_mean :truncated_mean

    # Calculates the statistical midrange.
    #
    # {Average#midrange}
    def midrange
      @midrange ||= Average.midrange(@data, &@block)
    end

    alias :midextreme :midrange

    # Calculates the statistical median.
    #
    # {Average#median}
    def median
      @median ||= Average.median(@data, &@block)
    end

    # Calculates the statistical modes.
    #
    # {Average#mode}
    def mode
      @mode ||= Average.mode(@data, &@block)
    end

  end
end
