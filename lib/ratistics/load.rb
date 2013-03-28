require 'zlib'
require 'csv'

module Ratistics

  # Helpers for loading sample data from comma separated value (CSV)
  # and fixed-width field (dat) files.
  module Load
    extend self

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

  end
end
