require 'spec_helper'

describe Ratistics do

  describe Ratistics::NilSampleError do

    specify { Ratistics::NilSampleError.new.should be_a StandardError }

    specify { Ratistics::NilSampleError.new('message').should be_a StandardError }
  end
end
