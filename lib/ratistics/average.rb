module Ratistics
  module Average
    extend self

    def mean(data)
      return 0 if data.empty?
      total = 0.0

      data.each do |item|
        if block_given?
          total = total + yield(item)
        else
          total = total + item
        end
      end

      return total / data.count.to_f
    end

    def median
    end

    def mode
    end

  end
end
