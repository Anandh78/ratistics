require 'zlib'
require 'csv'

module Ratistics

  # Helpers for loading sample data from comma separated value (CSV)
  # and fixed-width field (dat) files.
  module Load
    extend self

    # Convert an individual CSV record into a Ruby data structure
    # suitable for further processing. Leading and trailing
    # whitespace will be trimmed from all record values.
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
    # @param [String, Array] data the CSV data to be processed
    # @param [Hash] opts CSV parsing options
    #
    # @option opts [Array] :definition the record definition for processing
    #   individual fields (see above)
    # @option opts [Character] :col_sep column separator (default: ',')
    # @option opts [Character] :row_sep row separator (default: $/)
    # @option opts [Character] :quote_char quote character (default: '"')
    # @option opts [true, false] :headers the first row of the data/file =
    #   contains field name headers (default: false)
    #
    # @return [Array, Hash] an array of values when no record definition
    #   is given or a hash with keys matching the record definition
    def csv_record(data, opts = {})

      col_sep = opts[:col_sep] || ','
      col_sep_r = Regexp.escape(col_sep)
      quote_char_r = Regexp.escape(opts[:quote_char] || '"')
      line_regex = /(#{quote_char_r}[^#{quote_char_r}]*#{quote_char_r}#{col_sep_r})|(#{quote_char_r}[^#{quote_char_r}]*#{quote_char_r}$)|([^#{col_sep_r}]*#{col_sep_r})|([^#{col_sep_r}]+$)/
      quote_regex = /#{quote_char_r}/
      data = data.scan(line_regex).collect do |match|
        match.select{|m| ! m.nil? }.first.chomp(col_sep).gsub(quote_regex, '')
      end

      as = opts[:as]
      definition = opts[:definition] || opts[:def]
      unless definition.nil? || as == :frame || as == :dataframe
        field = (as == :array || as == :catalog || as == :catalogue ? [] : {})

        definition.each_index do |index|
          name, cast = definition[index]
          next if name.nil?
          if cast.is_a?(Symbol) && ! (data[index].nil? || data[index].empty?)
            value = data[index].send(cast)
          elsif cast.is_a?(Proc) && ! (data[index].nil? || data[index].empty?)
            value = cast.call(data[index])
          else
            value = data[index]
          end
          as == :array || as == :catalog || as == :catalogue ? field << [name, value] : field[name] = value
        end

        data = field
      end

      return data
    end

    # Convert an string representing multiple CSV records into an
    # array of Ruby data structures suitable for further processing.
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
    #   Record definitions work identically to #csv_record
    #
    # @example
    #   data = Ratistics::Load.csv_data(path)
    #   data = Ratistics::Load.csv_data(path, :def => definition)
    #   data = Ratistics::Load.csv_data(path, :hamster => true)
    #   data = Ratistics::Load.csv_data(path, :def => definition, :hamster => true)
    #   data = Ratistics::Load.csv_data(path, :hamster => :set)
    #   data = Ratistics::Load.csv_data(path, :def => definition, :hamster => :set)
    #
    # @param [String] data the CSV data to be processed
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
    #
    # @return [Array, Hamster] An array or Hamster collection containing
    #   all the records
    # 
    # @see #csv_record
    def csv_data(data, opts = {})

      definition = opts[:definition] || opts[:def]
      headers = opts[:headers] == true
      records = new_collection(opts[:hamster])

      data = data.split(opts[:row_sep] || $/)

      if definition.nil?
        options = opts.merge(as: :frame, def: nil, definition: nil)
        definition = csv_record(data.first.strip, options)
        unless headers
          definition.each_index{|i| definition[i] = "field_#{i+1}"}
        end
        opts = opts.merge(def: definition)
      end

      if opts[:as] == :frame || opts[:as] == :dataframe
        add_to_collection(records, definition.collect{|item| [item].flatten.first})
      end

#col_sep = opts[:col_sep] || ','
#col_sep_r = Regexp.escape(col_sep)
#quote_char_r = Regexp.escape(opts[:quote_char] || '"')
#line_regex = /(#{quote_char_r}[^#{quote_char_r}]*#{quote_char_r}#{col_sep_r})|(#{quote_char_r}[^#{quote_char_r}]*#{quote_char_r}$)|([^#{col_sep_r}]*#{col_sep_r})|([^#{col_sep_r}]+$)/
#quote_regex = /#{quote_char_r}/
      start = headers ? 1 : 0
      (start..data.length-1).each do |i|
        row = data[i].strip
        unless row.empty?
#row = row.scan(line_regex).collect do |match|
  #match.select{|m| ! m.nil? }.first.chomp(col_sep).gsub(quote_regex, '')
#end
#add_to_collection(records, row)
          add_to_collection(records, csv_record(row, opts))
        end
      end

      return records
    end

    def csv_file_to_frame(path, opts={})
      definition = opts[:definition] || opts[:def]
      headers = opts[:headers] == true

      row_sep_r = Regexp.escape(opts[:row_sep] || $/)
      col_sep_r = Regexp.escape(opts[:col_sep] || ',')
      quote_char_r = Regexp.escape(opts[:quote_char] || '"')
      line_regex = /(#{quote_char_r}[^#{quote_char_r}]*#{quote_char_r}#{col_sep_r})|(#{quote_char_r}[^#{quote_char_r}]*#{quote_char_r}$)|([^#{col_sep_r}]*#{col_sep_r})|([^#{col_sep_r}]+$)/
      quote_regex = /#{quote_char_r}/

      file = File.open(path, 'rb')
      contents = file.read
      file.close

      data = []
      contents = contents.split(row_sep_r)

      if definition.nil?
        definition = contents.first.strip.scan(line_regex).collect do |match|
          match.select{|m| ! m.nil? }.first.chomp(col_sep_r).gsub(quote_char_r, '')
        end
        if headers
          # use the first row for headers
          data << definition
        else
          # create bogus headers
          data << definition.length.times {|i| "column_#{i+1}"}
        end
      else
        # get the column names from the definition
      end

      start = headers ? 1 : 0
      (start..contents.length-1).each do |i|
        data << contents[i].strip.scan(line_regex).collect do |match|
          match.select{|m| ! m.nil? }.first.chomp(col_sep_r).gsub(quote_char_r, '')
        end
      end

      return data
    end

    # Convert a CSV file into an array of Ruby data structures
    # suitable for further processing.
    #
    # @note (see #csv_record)
    #
    # @param [String] path path to the CSV file
    # @param [Hash] opts CSV parsing options
    #
    # @option (see #csv_data)
    #
    # @return (see #csv_record)
    # 
    # @see #csv_record
    def csv_file(path, opts = {})
      #definition = opts[:definition] || opts[:def]
      #records = new_collection(opts[:hamster])
      #headers = (opts[:headers] == true)

      #File.open(path, 'r').each_line(opts[:row_sep] || $/) do |row|
        #row = row.force_encoding('ISO-8859-1').encode('utf-8', :replace => nil)
        #if headers
          #headers = false
          #opts = opts.merge(:definition => definition_from_header(row, opts))
        #else
          #records = add_to_collection(records, csv_record(row.strip, opts))
        #end
      #end

      #return records
    end

    # Convert a gzipped CSV file into an array of Ruby data structures
    # suitable for further processing.
    #
    # @note (see #csv_record)
    #
    # @param (see #csv_file)
    #
    # @option (see #csv_data)
    #
    # @return (see #csv_record)
    # 
    # @see #csv_record
    def csv_gz_file(path, opts = {})
      #definition = opts[:definition] || opts[:def]
      #records = new_collection(opts[:hamster])
      #headers = (opts[:headers] == true)

      #Zlib::GzipReader.open(path) do |gz|
        #gz.each_line do |row|
          #row = row.force_encoding('ISO-8859-1').encode('utf-8', :replace => nil)
          #if headers
            #headers = false
            #opts = opts.merge(:definition => definition_from_header(row, opts))
          #else
            #records = add_to_collection(records, csv_record(row.strip, opts))
          #end
        #end
      #end

      #return records
    end

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
    def dat_record(data, opts={})
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
    #   Record definitions work identically to #dat_record
    #
    # @example
    #   data = Ratistics::Load.dat_data(path, :def => definition)
    #   data = Ratistics::Load.dat_data(path, :def => definition, :hamster => true)
    #   data = Ratistics::Load.dat_data(path, :def => definition, :hamster => :set)
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
    # @see #dat_record
    def dat_data(data, opts = {})
      definition = opts[:definition] || opts[:def]
      records = new_collection(opts[:hamster])

      data.lines do |line|
        records = add_to_collection(records, dat_record(line, def: definition))
      end

      return records
    end

    # Convert a fixed field width data file representing multiple data
    # records into a collection of Ruby data structures suitable for further
    # processing.
    #
    # @note (see #dat_data)
    #
    # @param [String] path path to the data file
    # @param [Hash] opts processing options
    #
    # @option (see #dat_data)
    #
    # @return (see #dat_data)
    #
    # @see #dat_record
    def dat_file(path, opts = {})
      definition = opts[:definition] || opts[:def]
      records = new_collection(opts[:hamster])

      File.open(path, 'r').each do |line|
        line = line.force_encoding('ISO-8859-1').encode('utf-8', :replace => nil)
        records = add_to_collection(records, dat_record(line, def: definition))
      end

      return records
    end

    # Convert a gzipped fixed field width data file representing multiple
    # data records into a collection of Ruby data structures suitable for
    # further processing.
    #
    # @note (see #dat_data)
    #
    # @param (see #dat_file)
    #
    # @option (see #dat_data)
    #
    # @return (see #dat_data)
    #
    # @see #dat_record
    def dat_gz_file(path, opts = {})
      definition = opts[:definition] || opts[:def]
      records = new_collection(opts[:hamster])

      Zlib::GzipReader.open(path) do |gz|
        gz.each_line do |line|
          line = line.force_encoding('ISO-8859-1').encode('utf-8', :replace => nil)
          records = add_to_collection(records, dat_record(line, def: definition))
        end
      end

      return records
    end

    private

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

    # :nodoc:
    # @private
    #def definition_from_header(row, opts)
      #definition = opts[:definition] || opts[:def]
      #if definition.nil?
        #definition = add_to_collection([], csv_record(row.strip, opts))
        #definition = definition.flatten.collect{|field| field.to_sym }
      #end
      #return definition
    #end
  end
end
