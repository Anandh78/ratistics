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
      @first_quartile ||= Rank.first_quartile(@data)
    end

    alias :lower_quartile :first_quartile

    def second_quartile
      @second_quartile ||= Rank.second_quartile(@data)
    end

    def third_quartile
      @third_quartile ||= Rank.third_quartile(@data)
    end

    alias :upper_quartile :third_quartile

    #def each(&block)
    #end

    #def each_rank(&block)
    #end

    #def each_percentile(&block)
    #end

    #def percentile(value)
    #end

  end
end
