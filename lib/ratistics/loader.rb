require 'zlib'
require 'csv'

module Ratistics

  module Loader
    extend self

    # NOTE: Not skipping fields defined as nil or not included
    # in the definition

    def csv_file(path, opts = {})
      contents = file_contents(path)
      return csv_data(contents, opts)
    end

    def csv_gz_file(path, opts = {})
      contents = gz_contents(path)
      return csv_data(contents, opts)
    end

    def csv_data(contents, opts = {})
      if opts[:encoding] == :force
        contents = contents.force_encoding('ISO-8859-1').encode('utf-8', :replace => nil)
      end
      definition = opts[:def] || opts[:definition]

      if opts[:as] == :frame || opts[:as] == :dataframe
        if definition.nil?
          return frame_from_csv_data_using_headers(contents, opts)
        else
          return frame_from_csv_data_using_definition(contents, opts)
        end
      elsif opts[:as] == :array || opts[:as] == :catalog || opts[:as] == :catalogue
        if definition.nil?
          return catalog_from_csv_data_using_headers(contents, opts)
        else
          return catalog_from_csv_data_using_definition(contents, opts)
        end
      else
        if definition.nil?
          return hash_from_csv_data_using_headers(contents, opts)
        else
          return hash_from_csv_data_using_definition(contents, opts)
        end
      end
    end

    # Crater count: 384,343
    # Fastest load: ~15.5 seconds
    def frame_from_csv_data_using_definition(contents, opts={})

      definition = opts[:def] || opts[:definition]
      cfg = csv_config(opts)

      collection, put = new_collection(opts[:hamster])
      contents = contents.split(cfg[:row_regex])

      trans = definition.collect{|field| [field].flatten.length > 1 ? field.last : nil}
      collection << definition.collect{|field| [field].flatten.first}

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
        collection = collection.send(put, row)
      end

      return collection
    end

    # Crater count: 384,343
    # Fastest load: ~13.6 seconds
    def frame_from_csv_data_using_headers(contents, opts={})

      cfg = csv_config(opts)

      collection, put = new_collection(opts[:hamster])
      contents = contents.split(cfg[:row_regex])

      if cfg[:headers]
        collection = collection.send(put, contents.first.strip.scan(cfg[:field_regex]).collect do |match|
          match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
        end)
      else
        head = []
        collection = collection.send(put, head)
      end

      start = cfg[:headers] ? 1 : 0
      (start..contents.length-1).each do |i|
        collection = collection.send(put, contents[i].strip.scan(cfg[:field_regex]).collect do |match|
          match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
        end)
      end

      unless cfg[:headers]
        (1..collection.last.length).each{|i| head << "column_#{i}" }
      end

      return collection
    end

    # Crater count: 384,343
    # Fastest load: ~16.4 seconds
    def catalog_from_csv_data_using_definition(contents, opts={})

      definition = opts[:def] || opts[:definition]
      cfg = csv_config(opts)

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
        collection = collection.send(put, field_names.zip(row))
      end

      return collection
    end

    # Crater count: 384,343
    # Fastest load: ~15.4 seconds
    def catalog_from_csv_data_using_headers(contents, opts={})

      cfg = csv_config(opts)

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

    def hash_from_csv_data_using_definition(contents, opts={})

      definition = opts[:def] || opts[:definition]
      cfg = csv_config(opts)

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
          map[field] = row[index]
        end
        collection = collection.send(put, map)
      end

      return collection
    end

    def hash_from_csv_data_using_headers(contents, opts={})

      cfg = csv_config(opts)

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

    # :nodoc:
    # @private
    def gz_contents(path)
      contents = nil
      File.open(path, 'r') do |f|
        gz = Zlib::GzipReader.new(f)
        contents = gz.read
        gz.close
      end
      return contents
    end

    # :nodoc:
    # @private
    def file_contents(path)
      file = File.open(path, 'r')
      contents = file.read
      file.close
      return contents
    end

    # :nodoc:
    # @private
    def csv_config(opts)
      cfg = {
        headers: opts[:headers] == true,
        row_sep: Regexp.escape(opts[:row_sep] || $/),
        col_sep: Regexp.escape(opts[:col_sep] || ','),
        quote_char: Regexp.escape(opts[:quote_char] || '"'),
      }
      cfg[:row_regex] = /#{cfg[:row_sep]}/
      cfg[:field_regex] = /(#{cfg[:quote_char]}[^#{cfg[:quote_char]}]*#{cfg[:quote_char]}#{cfg[:col_sep]})|(#{cfg[:quote_char]}[^#{cfg[:quote_char]}]*#{cfg[:quote_char]}$)|([^#{cfg[:col_sep]}]*#{cfg[:col_sep]})|([^#{cfg[:col_sep]}]+$)/
      cfg[:quote_regex] = /#{cfg[:quote_char]}/
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
