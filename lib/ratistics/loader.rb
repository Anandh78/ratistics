require 'zlib'
require 'csv'

module Ratistics

  module Loader
    extend self

    # Crater count: 384,343
    # Fastest load: frame w/ header @ ~12.2 seconds
    # Fastest load: frame w/o header @ ~13.6 seconds
    def frame_from_csv_data_using_headers(contents, opts={})
      headers = opts[:headers] == true

      row_sep = Regexp.escape(opts[:row_sep] || $/)
      col_sep = Regexp.escape(opts[:col_sep] || ',')
      quote_char = Regexp.escape(opts[:quote_char] || '"')
      row_regex = /#{row_sep}/
      field_regex = /(#{quote_char}[^#{quote_char}]*#{quote_char}#{col_sep})|(#{quote_char}[^#{quote_char}]*#{quote_char}$)|([^#{col_sep}]*#{col_sep})|([^#{col_sep}]+$)/
      quote_regex = /#{quote_char}/

      frame = []
      contents = contents.split(row_regex)

      if headers
        frame << contents.first.strip.scan(field_regex).collect do |match|
          match.select{|m| ! m.nil? }.first.chomp(col_sep).gsub(quote_char, '')
        end
      else
        frame << [] # header placeholder
      end

      start = headers ? 1 : 0
      (start..contents.length-1).each do |i|
        frame << contents[i].strip.scan(field_regex).collect do |match|
          match.select{|m| ! m.nil? }.first.chomp(col_sep).gsub(quote_char, '')
        end
      end

      unless headers
        frame.last.length.times do |i|
          frame.first << "column_#{i}"
        end
      end

      return frame
    end

    def file_contents(path)
      file = File.open(path, 'r')
      contents = file.read
      file.close
      return contents
    end

  end
end
