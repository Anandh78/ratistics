require 'ratistics'

module Ratistics

  class ::Array

    def mean(&block)
      return Average.mean(self, &block)
    end
  end

end
