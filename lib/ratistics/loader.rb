require 'zlib'
require 'csv'

module Ratistics

  module Loader
    extend self

    # NOTE: Not skipping fields defined as nil or not included
    # in the definition

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

    # Crater count: 384,343
    # Fastest load: ~15.5 seconds
    def frame_from_csv_data_using_definition(contents, opts={})

      definition = opts[:def] || opts[:definition]
      cfg = csv_config(opts)

      frame = []
      contents = contents.split(cfg[:row_regex])

      trans = definition.collect{|field| [field].flatten.length > 1 ? field.last : nil}
      frame << definition.collect{|field| [field].flatten.first}

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
        frame << row
      end

      return frame
    end

    # Crater count: 384,343
    # Fastest load: ~13.6 seconds
    def frame_from_csv_data_using_headers(contents, opts={})

      cfg = csv_config(opts)

      frame = []
      contents = contents.split(cfg[:row_regex])

      if cfg[:headers]
        frame << contents.first.strip.scan(cfg[:field_regex]).collect do |match|
          match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
        end
      else
        frame << nil # header placeholder
      end

      start = cfg[:headers] ? 1 : 0
      (start..contents.length-1).each do |i|
        frame << contents[i].strip.scan(cfg[:field_regex]).collect do |match|
          match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
        end
      end

      unless cfg[:headers]
        frame[0] = (1..frame.last.length).collect{|i| "column_#{i}" }
      end

      return frame
    end

    # Crater count: 384,343
    # Fastest load: ~16.4 seconds
    def catalog_from_csv_data_using_definition(contents, opts={})

      definition = opts[:def] || opts[:definition]
      cfg = csv_config(opts)

      catalog = []
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
        catalog << field_names.zip(row)
      end

      return catalog
    end

    # Crater count: 384,343
    # Fastest load: ~15.4 seconds
    def catalog_from_csv_data_using_headers(contents, opts={})

      cfg = csv_config(opts)

      catalog = []
      contents = contents.split(cfg[:row_regex])

      field_names = contents.first.strip.scan(cfg[:field_regex]).collect do |match|
        match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
      end
      unless cfg[:headers]
        field_names = (1..field_names.length).collect{|i| "column_#{i}" }
      end

      start = cfg[:headers] ? 1 : 0
      (start..contents.length-1).each do |i|
        catalog << field_names.zip(contents[i].strip.scan(cfg[:field_regex]).collect do |match|
          match.select{|m| ! m.nil? }.first.chomp(cfg[:col_sep]).gsub(cfg[:quote_char], '')
        end)
      end

      return catalog
    end

    def file_contents(path)
      file = File.open(path, 'r')
      contents = file.read
      file.close
      return contents
    end

  end
end
