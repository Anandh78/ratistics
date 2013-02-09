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

      @ranks = Rank.ranks(data, opts, &block).freeze
      @ranks ||= []

      @percent_ranks = {}
      @percentiles = {}
    end

    def percent_rank(index)
      @percent_ranks[index] ||= Rank.percent_rank(@data, index, :sorted => true)
    end

    def nearest_rank(percentile, opts={})
      opts = opts.merge(:sorted => true)
      @percentiles[percentile] ||= Rank.nearest_rank(@data, percentile, opts)
    end

    def linear_rank(percentile, opts={})
    end

  end
end
