require 'zlib'
require 'csv'

module Ratistics

  module Load
    module Dat
      extend self

      # Convert an individual fixed-length field record into a Ruby
      # hash suitable for further processing. Leading and trailing
      # whitespace will be trimmed from all record values.
      #
      # The second parameter is a record definition which describes
      # individual fields in the record. Only fields defined in the 
      # record definition will be included in the returned hash. A
      # record definition is an array of hashes where each individual
      # hash represents a single field in the record.
      #
      # Each field hash must include at least three values:
      # * *:field* The name of the field
      # * *:start* The starting index of the field
      # * *:end* The end index of the field
      #
      # The *:field* name can be any Ruby data type that Hash supports
      # as a key. The *:start* and *:end* values must be intengers greater
      # than or equal to one (1). Columns in the record are numbered
      # starting at one (1), unlike Ruby arrays. The data for a field
      # will be all the character from the *:start* to the *:end*,
      # inclusive. Any columns in the file not described by fields in
      # the record definition will be ingnored.
      #
      # The fourth (optional) value in the field definition, *:cast*,
      # must be either a symbol or a lambda. When a symbol is given the
      # corresponding method will be called on the data value before
      # being returned. For example, to convert the data to an integer
      # pass *:to_i* as the *:cast* and the *#to_i* method will be called.
      # When the *:cast* is a lambda the block must accept exactly one
      # parameter. The lambda will be called for the field and the
      # string field value will be passed as the block the argument.
      # The use of lambdas this way allows for complex field processing.
      #
      # @example Simple field definition
      #   definition = [
      #     {:field => :place, :start => 1, :end => 6},
      #     {:field => :div, :start =>  16, :end => 21},
      #     {:field => :nettime, :start =>  30, :end => 38},
      #     {:field => :pace, :start =>  39, :end => 44},
      #     {:field => :name, :start =>  45, :end => 67},
      #     {:field => :age, :start =>  68, :end => 70},
      #     {:field => :gender, :start =>  71, :end => 72},
      #     {:field => :race_num, :start =>  73, :end => 78},
      #   ]
      #
      # @example Complex field definition
      #   definition = [
      #     {:field => :place, :start => 1, :end => 6, :cast => lambda {|i| i.to_i} },
      #     {:field => :div_tot, :start =>  7, :end => 15},
      #     {:field => :div, :start =>  16, :end => 21},
      #     {:field => :guntime, :start =>  22, :end => 29},
      #     {:field => :nettime, :start =>  30, :end => 38},
      #     {:field => :pace, :start =>  39, :end => 44},
      #     {:field => :name, :start =>  45, :end => 67},
      #     {:field => :age, :start =>  68, :end => 70, :cast => :to_i},
      #     {:field => :gender, :start =>  71, :end => 72},
      #     {:field => :race_num, :start =>  73, :end => 78, :cast => :to_i},
      #     {:field => :city_state, :start =>  79, :end => 101},
      #   ]
      #
      # @param [String] data the data to be processed
      # @param [Hash] opts processing options
      #
      # @option opts [Array] :definition the record definition for processing
      #   individual fields (required, see above)
      #
      # @return [Hash] a hash with keys matching the fields in the record definition
      def record(data, opts={})
        definition = opts[:definition] || opts[:def]
        record = {}

        definition.each do |field|
          name = field[:field]
          record[name] = data.slice(field[:start]-1, field[:end]-field[:start]+1).strip
          unless record[name].nil? || record[name].empty?
            if field[:cast].is_a? Symbol
              record[name] = record[name].send(field[:cast])
            elsif field[:cast].is_a? Proc
              record[name] = field[:cast].call(record[name])
            end
          end
        end

        return record
      end

      # Convert a string representing multiple data records into a
      # collection of Ruby data structures suitable for further processing.
      #
      # By default the return value is a Ruby Array. If the Hamster gem
      # is installed a Hamster collection can be returned instead.
      # To return a Hamster collection set the *:hamster* option
      # to *true*. Optionally, a specific Hamster class can be specified
      # by setting the *:hamster* option to a symbol specifying the type
      # to return. For example, *:hamster => :set* will set the return
      # type to Hamster::Set. The default Hamster return type is
      # Hamster::Vector.
      #
      # @note
      #   Record definitions work identically to #record
      #
      # @example
      #   data = Ratistics::Load.data(path, :def => definition)
      #   data = Ratistics::Load.data(path, :def => definition, :hamster => true)
      #   data = Ratistics::Load.data(path, :def => definition, :hamster => :set)
      #
      # @param [String] data the data to be processed
      # @param [Hash] opts processing options
      #
      # @option opts [Array] :definition the record definition for processing
      #   individual fields (required, see above)
      # @option opts [Symbol] :hamster (false) set to *true* to return a
      #   Hamster collection, or indicate a specific Hamster return type
      #
      # @return [Array, Hamster] An array or Hamster collection containing
      #   all the records
      #
      # @see #record
      def data(data, opts = {})
        definition = opts[:definition] || opts[:def]
        records = new_collection(opts[:hamster])

        data.lines do |line|
          records = add_to_collection(records, record(line, def: definition))
        end

        return records
      end

      # Convert a fixed field width data file representing multiple data
      # records into a collection of Ruby data structures suitable for further
      # processing.
      #
      # @note (see #data)
      #
      # @param [String] path path to the data file
      # @param [Hash] opts processing options
      #
      # @option (see #data)
      #
      # @return (see #data)
      #
      # @see #record
      def file(path, opts = {})
        definition = opts[:definition] || opts[:def]
        records = new_collection(opts[:hamster])

        File.open(path, 'r').each do |line|
          line = line.force_encoding('ISO-8859-1').encode('utf-8', :replace => nil)
          records = add_to_collection(records, record(line, def: definition))
        end

        return records
      end

      # Convert a gzipped fixed field width data file representing multiple
      # data records into a collection of Ruby data structures suitable for
      # further processing.
      #
      # @note (see #data)
      #
      # @param (see #file)
      #
      # @option (see #data)
      #
      # @return (see #data)
      #
      # @see #record
      def gz_file(path, opts = {})
        definition = opts[:definition] || opts[:def]
        records = new_collection(opts[:hamster])

        Zlib::GzipReader.open(path) do |gz|
          gz.each_line do |line|
            line = line.force_encoding('ISO-8859-1').encode('utf-8', :replace => nil)
            records = add_to_collection(records, record(line, def: definition))
          end
        end

        return records
      end

      private

      #================================================================
      #================================================================

      # :nodoc:
      # @private
      def new_collection(type)
        if type.nil? || type == false
          collection = Array.new
        elsif Hamster.respond_to?(type.to_s)
          collection = Hamster.send(type.to_s)
        else
          collection = Hamster.vector
        end
        return collection
      end

      # :nodoc:
      # @private
      def add_to_collection(collection, item)
        if collection.respond_to? :<<
          return collection << item
        else
          return collection.cons(item)
        end
      end
    end
  end
end
