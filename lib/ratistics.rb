$:.push File.join(File.dirname(__FILE__))

require 'ratistics/average'
require 'ratistics/distribution'
require 'ratistics/histogram'
require 'ratistics/version'

module Ratistics
  class << self
    include Average
    include Distribution
    include Histogram
  end
end
