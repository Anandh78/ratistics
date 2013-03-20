require 'ratistics'

module Ratistics

  class ::Hash

    def to_catalog
      catalog = []
      self.each do |key, value|
        value = yield(value) if block_given?
        catalog << [key, value]
      end
      return catalog
    end

    alias :to_catalogue :to_catalog
  end
end
