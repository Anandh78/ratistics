require 'zlib'
require 'csv'

module Ratistics

  module Load
    extend self

    def csv_record(data, definition = nil, opts = {})

      if data.is_a? String
        data = CSV.parse(data, opts) {|row| break(row) }
      end

      unless definition.nil?
        field = {}
        definition.each_index do |index|
          name, cast = definition[index]
          if cast.is_a? Symbol
            field[name] = data[index].send(cast)
          elsif cast.is_a? Proc
            field[name] = cast.call(data[index])
          else
            field[name] = data[index]
          end
        end
        data = field
      end

      return data
    end

    def csv_data(data, definition = nil, opts = {})
      records = []

      CSV.parse(data, opts) do |row|
        records << csv_record(row, definition)
      end

      return records
    end

    def csv_file(path, definition = nil, opts = {})
      records = []

      CSV.foreach(path, opts) do |row|
        records << csv_record(row, definition)
      end

      return records
    end

    def csv_gz_file(path, definition = nil, opts = {})
      records = []

      Zlib::GzipReader.open(path) do |gz|
        gz.each_line do |line|
          records << csv_record(line, definition, opts)
        end
      end

      return records
    end

    def dat_record(data, definition)
      record = {}

      definition.each do |field|
        name = field[:field]
        record[name] = data.slice(field[:start]-1, field[:end]-field[:start]+1).strip
        if field[:cast].is_a? Symbol
          record[name] = record[name].send(field[:cast])
        elsif field[:cast].is_a? Proc
          record[name] = field[:cast].call(record[name])
        end
      end

      return record
    end

    def dat_data(data, definition)
      records = []

      data.lines do |line|
        records << dat_record(line, definition)
      end

      return records
    end

    def dat_file(path, definition)
      records = []

      File.open(path).each do |line|
        records << dat_record(line, definition)
      end

      return records
    end

    def dat_gz_file(path, definition)
      records = []

      Zlib::GzipReader.open(path) do |gz|
        gz.each_line do |line|
          records << dat_record(line, definition)
        end
      end

      return records
    end

  end
end
