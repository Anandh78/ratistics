require 'ratistics/average'
require 'ratistics/collection'
require 'ratistics/rank'

module Ratistics

  class Percentiles

    attr_reader :ranks

    alias :percentiles :ranks
    alias :centiles :ranks

    def initialize(data, opts={}, &block)
      raise ArgumentError.new('data cannot be nil') if data.nil?
      if block_given?
        @data = []
        data.each do |item|
          @data << yield(item)
        end
      elsif opts[:sorted] == true
        @data = data
      else 
        @data = data.sort
      end

      @ranks = Rank.ranks(@data, {:sorted => true}).freeze
      @ranks ||= []

      @percent_ranks = {}
      @nearest_ranks = {}
      @linear_ranks = {}
    end

    def percent_rank(index)
      @percent_ranks[index] ||= Rank.percent_rank(@data, index, :sorted => true)
    end

    def nearest_rank(percentile, opts={})
      opts = opts.merge(:sorted => true)
      @nearest_ranks[percentile] ||= Rank.nearest_rank(@data, percentile, opts)
    end

    def linear_rank(percentile, opts={})
      opts = opts.merge(:sorted => true)
      @linear_ranks[percentile] ||= Rank.linear_rank(@data, percentile, opts)
    end

    def first_quartile
      midpoint = (@data.size / 2.0).floor - 1
      @first_quartile ||= Average.median(Collection.slice(@data, (0..midpoint)))
    end

    alias :lower_quartile :first_quartile

    def second_quartile
      @second_quartile ||= Average.median(@data)
    end

    def third_quartile
      midpoint = (@data.size / 2.0).ceil
      high = @data.size - 1
      @third_quartile ||= Average.median(Collection.slice(@data, (midpoint..high)))
    end

    alias :upper_quartile :third_quartile

  end
end
