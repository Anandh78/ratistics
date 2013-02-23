module Ratistics

  class Catalog

    def initialize(data=nil, opts={})
      from = "from_#{opts[:from]}".to_sym
      if Catalog.respond_to?(from)
        @data = Catalog.send(from, data)
        @data = @data.instance_variable_get(:@data)
      else
        @data = []
      end
    end

    def self.from_hash(data = {}, &block)
      collected = []
      data.each do |key, value|
        value = yield(value) if block_given?
        collected << [key, value]
      end
      catalog = Catalog.new
      catalog.instance_variable_set(:@data, collected)
      return catalog
    end

    def self.from_array(*args, &block)
      collected = []
      data = args.flatten

      max = ((data.size % 2 == 0) ? data.size-1 : data.size-2)
      (0..max).step(2) do |index|
        key = block_given? ? yield(data[index]) : data[index]
        value = block_given? ? yield(data[index+1]) : data[index+1]
        collected << [key, value]
      end

      catalog = Catalog.new
      catalog.instance_variable_set(:@data, collected)
      return catalog
    end

    def self.from_catalog(*args, &block)
      collected = []

      if args.size > 1
        data = args
      elsif args.size == 1 && args.first.size == 2
        data = args
      else
        data = args.first
      end

      data.each do |item|
        if block_given?
          collected << [item.first, yield(item.last)]
        else
          collected << item
        end
      end
      
      catalog = Catalog.new
      catalog.instance_variable_set(:@data, collected)
      return catalog
    end

    class << self
      alias :from_catalogue :from_catalog
    end

    def empty?
      size == 0
    end

    def size
      @data.size
    end

    alias :length :size

    def first
      @data.first
    end

    def last
      @data.last
    end

    def raw
      return @data.dup
    end

  end

  class Catalogue < Catalog; end
end
