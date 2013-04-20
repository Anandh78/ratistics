require 'ratistics/load'

require 'zlib'
require 'csv'

module Ratistics

  module Load
    module Csv
      extend self

      # Convert a gzipped CSV file into an array of Ruby data structures
      # suitable for further processing.
      #
      # @example (see #csv_data)
      #
      # @param [String] path path to the CSV file
      # @param [Hash] opts CSV parsing options
      #
      # @option (see #csv_data)
      #
      # @return (see #csv_data)
      # 
      # @see #csv_data
      def file(path, opts = {})
        contents = Ratistics::Load.file_contents(path)
        return data(contents, opts)
      end

      # Convert a gzipped CSV file into an array of Ruby data structures
      # suitable for further processing.
      #
      # @example (see #csv_data)
      #
      # @param [String] path path to the CSV file
      # @param [Hash] opts CSV parsing options
      #
      # @option (see #csv_data)
      #
      # @return (see #csv_data)
      # 
      # @see #csv_data
      def gz_file(path, opts = {})
        contents = Ratistics::Load.gz_contents(path)
        return data(contents, opts)
      end

      # Convert an string representing multiple CSV records into an
      # array of Ruby data structures suitable for further processing.
      # Leading and trailing whitespace will be trimmed from all values.
      #
      # The second parameter is an optional record definition which
      # describes individual fields in the CSV record. There
      # is one element in the record definition for each field in the
      # record. When a definition is omitted the record will be returned
      # as an array with one element for every field in the CSV.
      # The array will be ordered according to the original record. When
      # a record definition is given the record will be returned as a
      # hash with one key for every field in the definition. If
      # there are fewer fields in the definition than in the record
      # only the first *n* fields will be returned, where *n* is the
      # number of fields in the definition. Fields defined as *nil*
      # will also be skipped.
      #
      # Each field in the definition can consist of up to two values.
      # When two values are given the field definition must be an array.
      # When only one value is given the field can be a single-element
      # array or just the value. The first value for each field definition
      # can be any data type. It is the field name (key for the returned
      # hash). The second (optional) value must be either a symbol or
      # a lambda. When a symbol is given the corresponding method will
      # be called on the data value before being returned. For example,
      # to convert the data to an integer pass *:to_i* as the second
      # field element and the *#to_i* method will be called. When the
      # second element is a lambda the block must accept exactly one
      # parameter. The lambda will be called for the field and the
      # string field value will be passed as the block the argument.
      # The use of lambdas this way allows for complex field processing.
      #
      # By default the return value is a Ruby Hash. If the Hamster gem
      # is installed a Hamster collection can be returned instead.
      # To return a Hamster collection set the *:hamster* option
      # to *true*. Optionally, a specific Hamster class can be specified
      # by setting the *:hamster* option to a symbol specifying the type
      # to return. For example, *:hamster => :set* will set the return
      # type to Hamster::Set. The default Hamster return type is
      # Hamster::Vector.
      #
      # @example Simple field definition
      #   definition = [
      #     :place,
      #     :div_tot,
      #     :div,
      #     :guntime,
      #     :nettime,
      #     :pace,
      #     :name,
      #     :age,
      #     :gender,
      #     :race_num,
      #     :city_state
      #   ]
      #
      # @example Complex field definition
      #   definition = [
      #     [:place, lambda {|i| i.to_i}],
      #     nil,
      #     :div,
      #     :guntime,
      #     :nettime,
      #     :pace,
      #     [:name],
      #     [:age, :to_i],
      #     [:gender],
      #     [:race_num, :to_i],
      #     [:city_state]
      #   ]
      #
      # @example
      #   data = Ratistics::Load.csv_data(path)
      #   data = Ratistics::Load.csv_data(path, :def => definition)
      #   data = Ratistics::Load.csv_data(path, :hamster => true)
      #   data = Ratistics::Load.csv_data(path, :def => definition, :hamster => true)
      #   data = Ratistics::Load.csv_data(path, :hamster => :set)
      #   data = Ratistics::Load.csv_data(path, :def => definition, :hamster => :set)
      #
      # @param [String] contents the CSV data to be processed
      # @param [Hash] opts CSV parsing options
      #
      # @option opts [Array] :definition the record definition for processing
      #   individual fields (see above)
      # @option opts [Symbol] :hamster (false) set to *true* to return a
      #   Hamster collection, or indicate a specific Hamster return type
      # @option opts [Character] :col_sep column separator (default: ',')
      # @option opts [Character] :row_sep row separator (default: $/)
      # @option opts [Character] :quote_char quote character (default: '"')
      # @option opts [true, false] :headers the first row of the data/file =
      #   contains field name headers (default: false)
      # @option opts [Symbol] :as the data type/structure of the individual
      #   records, :hash/:map (default), :array/:catalog/:catalogue
      #
      # @return [Array, Hamster] An array or Hamster collection containing
      #   all the records
      def data(contents, opts = {})
        if opts[:encoding] == :force
          contents = contents.force_encoding('ISO-8859-1').encode('utf-8', :replace => nil)
        end
        definition = opts[:def] || opts[:definition]

        if opts[:as] == :array || opts[:as] == :catalog || opts[:as] == :catalogue
          if definition.nil?
            return catalog_from_data_using_headers(contents, opts)
          else
            return catalog_from_data_using_definition(contents, opts)
          end
        else
          if definition.nil?
            return hash_from_data_using_headers(contents, opts)
          else
            return hash_from_data_using_definition(contents, opts)
          end
        end
      end

      #================================================================
      private
      #================================================================

      # Crater count: 384,343
      # Fastest load: ~16.4 seconds
      # :nodoc:
      # @private
      def catalog_from_data_using_definition(contents, opts={})

        definition = opts[:def] || opts[:definition]
        cfg = config(opts)

        collection, put = new_collection(opts[:hamster])
        contents = contents.split(cfg[:row_regex])

        field_names = definition.collect{|field| [field].flatten.first}
        keepers = field_names.dup.delete_if{|field| field.nil?}
        trans = definition.collect{|field| [field].flatten.length > 1 ? field.last : nil}

        start = cfg[:headers] ? 1 : 0
        (start..contents.length-1).each do |i|
          row = contents[i].strip.scan(cfg[:field_regex]).collect do |match|
            match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
          end
          (row.size-1).downto(0) do |i|
            if field_names[i].nil?
              row.delete_at(i)
            elsif !trans[i].nil? && !row[i].nil? && !row[i].empty?
              row[i] = row[i].send(trans[i]) if trans[i].is_a?(Symbol)
              row[i] = trans[i].call(row[i]) if trans[i].is_a?(Proc)
            end
          end
          collection = collection.send(put, keepers.zip(row))
        end

        return collection
      end

      # Crater count: 384,343
      # Fastest load: ~15.4 seconds
      # :nodoc:
      # @private
      def catalog_from_data_using_headers(contents, opts={})

        cfg = config(opts)

        collection, put = new_collection(opts[:hamster])
        contents = contents.split(cfg[:row_regex])

        field_names = contents.first.strip.scan(cfg[:field_regex]).collect do |match|
          match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
        end
        unless cfg[:headers]
          field_names = (1..field_names.length).collect{|i| "column_#{i}" }
        end

        start = cfg[:headers] ? 1 : 0
        (start..contents.length-1).each do |i|
          collection << field_names.zip(contents[i].strip.scan(cfg[:field_regex]).collect do |match|
            match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
          end)
        end

        return collection
      end

      # :nodoc:
      # @private
      def hash_from_data_using_definition(contents, opts={})

        definition = opts[:def] || opts[:definition]
        cfg = config(opts)

        collection, put = new_collection(opts[:hamster])
        contents = contents.split(cfg[:row_regex])

        field_names = definition.collect{|field| [field].flatten.first}
        trans = definition.collect{|field| [field].flatten.length > 1 ? field.last : nil}

        start = cfg[:headers] ? 1 : 0
        (start..contents.length-1).each do |i|
          row = contents[i].strip.scan(cfg[:field_regex]).collect do |match|
            match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
          end
          row.size.times do |i|
            unless trans[i].nil? || row[i].nil? || row[i].empty?
              row[i] = row[i].send(trans[i]) if trans[i].is_a?(Symbol)
              row[i] = trans[i].call(row[i]) if trans[i].is_a?(Proc)
            end
          end
          map = {}
          field_names.each_with_index do |field, index|
            map[field] = row[index] unless field_names[index].nil?
          end
          collection = collection.send(put, map)
        end

        return collection
      end

      # :nodoc:
      # @private
      def hash_from_data_using_headers(contents, opts={})

        cfg = config(opts)

        collection, put = new_collection(opts[:hamster])
        contents = contents.split(cfg[:row_regex])

        field_names = contents.first.strip.scan(cfg[:field_regex]).collect do |match|
          match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
        end
        unless cfg[:headers]
          field_names = (1..field_names.length).collect{|i| "column_#{i}" }
        end

        start = cfg[:headers] ? 1 : 0
        (start..contents.length-1).each do |i|
          row = contents[i].strip.scan(cfg[:field_regex]).collect do |match|
            match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
          end
          map = {}
          field_names.each_with_index do |field, index|
            map[field] = row[index]
          end
          collection = collection.send(put, map)
        end

        return collection
      end

      #================================================================
      private
      #================================================================

      # :nodoc:
      # @private
      def config(opts)
        cfg = {}
        cfg[:headers] = opts[:headers] == true

        cfg[:row_sep] = (opts[:row_sep] || $/)
        cfg[:col_sep] = (opts[:col_sep] || ',')
        cfg[:quote_char] = (opts[:quote_char] || '"')

        cfg[:row_sep_r] = Regexp.escape(cfg[:row_sep])
        cfg[:col_sep_r] = Regexp.escape(cfg[:col_sep])
        cfg[:quote_char_r] = Regexp.escape(cfg[:quote_char])

        cfg[:row_regex] = /#{cfg[:row_sep_r]}/
          cfg[:field_regex] = /(#{cfg[:quote_char_r]}[^#{cfg[:quote_char_r]}]*#{cfg[:quote_char_r]}#{cfg[:col_sep_r]})|(#{cfg[:quote_char_r]}[^#{cfg[:quote_char_r]}]*#{cfg[:quote_char_r]}$)|([^#{cfg[:col_sep_r]}]*#{cfg[:col_sep_r]})|([^#{cfg[:col_sep_r]}]+$)/
          cfg[:quote_regex] = /#{cfg[:quote_char_r]}/

          return cfg
      end

      # :nodoc:
      # @private
      def new_collection(type)
        if type.nil? || type == false
          collection = Array.new
          method = :<<
        elsif Hamster.respond_to?(type.to_s)
          collection = Hamster.send(type.to_s)
          method = collection.respond_to?(:<<) ? :<< : :cons
        else
          collection = Hamster.vector
          method = :cons
        end
        return collection, method
      end
    end
  end
end
