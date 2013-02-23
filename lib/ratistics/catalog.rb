module Ratistics

  class Catalog

    def initialize(data=nil, opts={})

      from = "from_#{opts[:from]}".to_sym
      if Catalog.respond_to?(from)
        @data = Catalog.send(from, data)
        @data = @data.instance_variable_get(:@data)
      elsif opts[:from].nil? && !data.nil?
        @data = Catalog.from_catalog(data)
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

    def self.from_catalog(data, *args, &block)
      collected = []

      if args.empty? && data.size == 2 && !data.first.is_a?(Array)
        # Catalog.from_catalog([:one, 1])
        data = [data]
      elsif !args.empty?
        #Catalog.from_catalog([:one, 1], [:two, 2], [:three, 3])
        data = [data] + args
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

    def ==(other)
      if other.is_a? Catalog
        return (@data == other.instance_variable_get(:@data))
      elsif other.is_a? Array
        return (@data == other)
      else
        return false
      end
    end

    alias :eq '=='.to_sym

    def [](index)
      datum = @data[index]
      return (datum.nil? ? nil : datum.dup)
    end

    def []=(index, value)
      if (index >= 0 && index >= @data.size) || (index < 0 && index.abs > @data.size)
        raise ArgumentError.new('index must reference an existing element')
      elsif value.is_a?(Hash) && value.size == 1
        @data[index] = [value.keys.first, value.values.first]
      elsif value.is_a?(Array) && value.size == 2
        @data[index] = value.dup
      else
        raise ArgumentError.new('value must be a one-element hash or a two-element array')
      end
    end

    def to_s
      return @data.to_s
    end

    def &(other)
      other = other.instance_variable_get(:@data) if other.is_a?(Catalog)
      if other.is_a? Array
        return Catalog.from_catalog(@data & other)
      else
        raise TypeError.new("can't convert #{other.class} into Catalog")
      end
    end

    def +(other)
      other = other.instance_variable_get(:@data) if other.is_a?(Catalog)
      if other.is_a? Array
        return Catalog.from_catalog(@data + other)
      else
        raise TypeError.new("can't convert #{other.class} into Catalog")
      end
    end

    def |(other)
      other = other.instance_variable_get(:@data) if other.is_a?(Catalog)
      if other.is_a? Array
        return Catalog.from_catalog(@data | other)
      else
        raise TypeError.new("can't convert #{other.class} into Catalog")
      end
    end

  end

  class Catalogue < Catalog; end
end
