module Ratistics

  module Percentile
    extend self

    #  The value of a variable below which a certain percent of observations fall 
    def percentile(data, percentile, sorted=false, opts={}, &block)
      # opts[:interpolate] = false
    end

    alias :centile, :percentile

    def percentile?(data, percentile, value, sorted=false, &block)
    end

    alias :centile?, :percentile?

    # The percentage of scores in the frequency distribution that are the same or lower
    def percentile_rank(data, value, sorted=false, &block)
    end

    alias :centile_rank, :percentile_rank

    def percentile_rank?(data, value, percentile, sorted=false, &block) 
    end

    alias :centile_rank?, :percentile_rank?

    #def lower_quartile
    #def upper_quartile
    #def first_quartile
    #def second_quartile
    #def third_quartile

  end
end
