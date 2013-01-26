require 'zlib'
require 'csv'

module Ratistics

  module Load
    extend self

    def csv_record(data, definition = nil)

      data = CSV.parse(data) {|row| break(row) } if data.is_a? String

      unless definition.nil?
        field = {}
        definition.each_index do |index|
          field[definition[index]] = data[index]
        end
        data = field
      end

      return data
    end

    def csv_data(data, definition = nil)
      records = []

      CSV.parse(data) do |row|
        records << csv_record(row, definition)
      end

      return records
    end

    def csv_file(path, definition = nil)
      records = []

      CSV.foreach(path) do |row|
        records << csv_record(row, definition)
      end

      return records
    end

    def csv_gz_file(path, definition = nil)
      records = []

      Zlib::GzipReader.open(path) do |gz|
        gz.each_line do |line|
          records << csv_record(line, definition)
        end
      end

      return records
    end

    def dat_record(data, definition)
      record = {}

      definition.each do |field|
        record[field[:field]] = data.slice(field[:start]-1, field[:end]-field[:start]+1).strip
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
