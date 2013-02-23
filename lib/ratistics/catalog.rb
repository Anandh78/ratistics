module Ratistics

  class Catalog

    def initialize(data=nil, opts={})

      if block_given?

        @data = []
        data.each do |item|
          @data << yield(item)
        end

      else
        from = opts[:from]
        from = :array if [:set, :list, :stack, :queue, :vector].include?(from)
        from = "from_#{from}".to_sym

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

    alias :eq :==
    alias :equals :==

    def <=>(other)
      other = other.instance_variable_get(:@data) if other.is_a?(Catalog)
      if other.is_a? Array
        return @data <=> other
      else
        raise TypeError.new("can't convert #{other.class} into Catalog")
      end
    end

    alias :compare :<=>
    alias :compare_to :<=>

    def [](index)
      datum = @data[index]
      return (datum.nil? ? nil : datum.dup)
    end

    alias :at :[]

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

    alias :intersection :&

    def +(other)
      other = other.instance_variable_get(:@data) if other.is_a?(Catalog)
      if other.is_a? Array
        return Catalog.from_catalog(@data + other)
      else
        raise TypeError.new("can't convert #{other.class} into Catalog")
      end
    end

    alias :add :+
    alias :sum :+

    def |(other)
      other = other.instance_variable_get(:@data) if other.is_a?(Catalog)
      if other.is_a? Array
        return Catalog.from_catalog(@data | other)
      else
        raise TypeError.new("can't convert #{other.class} into Catalog")
      end
    end

    alias :union :|

    def push(item)
      if item.is_a?(Hash) && item.size == 1
        @data << [item.keys.first, item.values.first]
        return self
      elsif item.is_a?(Array) && item.size == 2
        @data << item
        return self
      else
        raise TypeError.new("can't convert #{other.class} into Catalog")
      end
    end

    alias :<< :push
    alias :append :push

    def pop
      if self.empty?
        return nil
      else
        return @data.pop
      end
    end

    def peek
      if self.empty?
        return nil
      else
        return @data.last.dup
      end
    end

    def keys
      return @data.collect{|item| item.first}
    end

    def values
      return @data.collect{|item| item.last}
    end

    def each(&block)
      @data.each do |item|
        yield(item)
      end
    end

    def each_pair(&block)
      @data.each do |item|
        yield(item.first, item.last)
      end
    end

    def each_key(&block)
      @data.each do |item|
        yield(item.first)
      end
    end

    def each_value(&block)
      @data.each do |item|
        yield(item.last)
      end
    end

    def include?(key=nil, value=nil)
      if key && value
        return @data.include?([key, value])
      elsif key.is_a?(Array)
        return @data.include?(key)
      elsif key.is_a?(Hash) && key.size == 1
        return @data.include?([key.keys.first, key.values.first])
      else
        return false
      end
    end

    def slice(index, length=nil)
      if length.nil?
        catalog = @data.slice(index)
      else
        catalog = @data.slice(index, length)
      end
      return Catalog.new(catalog)
    end

    def slice!(index, length=nil)
      if length.nil?
        catalog = @data.slice!(index)
      else
        catalog = @data.slice!(index, length)
      end
      return Catalog.new(catalog)
    end

    def sort_by_key
      sorted = @data.sort{|a, b| a.first <=> b.first}
      return Catalog.new(sorted)
    end

    def sort_by_key!
      sorted = @data.sort!{|a, b| a.first <=> b.first}
      return self
    end

    def sort_by_value
      sorted = @data.sort{|a, b| a.last <=> b.last}
      return Catalog.new(sorted)
    end

    def sort_by_value!
      sorted = @data.sort!{|a, b| a.last <=> b.last}
      return self
    end

    def sort(&block)
      sorted = @data.sort(&block)
      return Catalog.new(sorted)
    end

    def sort!(&block)
      sorted = @data.sort!(&block)
      return self
    end

    def to_a
      catalog = []
      @data.each do |item|
        catalog << item.first << item.last
      end
      return catalog
    end

    def to_hash
      catalog = {}
      @data.each do |item|
        catalog[item.first] = item.last
      end
      return catalog
    end

    def to_catalog
      return @data.dup
    end

    alias :to_catalogue :to_catalog

    def delete(key, value=nil, &block)
      item = nil

      if key && value
        item = @data.delete([key, value])
      elsif key.is_a? Array
        item = @data.delete(key)
      elsif key.is_a? Hash
        item = @data.delete([key.keys.first, key.values.first])
      end

      item = yield if item.nil? && block_given?
      return item
    end

    def delete_at(index)
      item = @data.delete_at(index)
      item = yield if item.nil? && block_given?
      return item
    end

    def delete_if(&block)
      raise ArgumentError.new('no block supplied') unless block_given?
      if block.arity <= 1
        items = @data.delete_if(&block)
      else
        items = []
        @data.each do |key, value|
          items << [key, value] if yield(key, value)
        end
        items.each {|item| @data.delete(item)}
      end
      return self
    end

  end

  class Catalogue < Catalog; end
end
