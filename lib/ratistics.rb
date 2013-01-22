$:.push File.join(File.dirname(__FILE__))

require 'ratistics/average'
require 'ratistics/version'

module Ratistics
  class << self
    include Average
  end

end
