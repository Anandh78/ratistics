$:.push File.join(File.dirname(__FILE__))

require 'ratistics/average'
require 'ratistics/distribution'
require 'ratistics/version'

# Ratistics provides basic statistical computation functions
# to Ruby programmers. It is intended for small data sets only.
# This gem was designed for simplicity. Very little consideration
# was given to performance.
module Ratistics
  class << self
    include Average
    include Distribution
  end

end
