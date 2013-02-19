require 'spec_helper'

describe Ratistics do

  describe Ratistics::NilSampleError do

    specify { Ratistics::NilSampleError.new.should be_a StandardError }

    specify { Ratistics::NilSampleError.new('message').should be_a StandardError }
  end

  specify '#aggregates creates a new Aggregates object' do
    Ratistics.aggregates([1, 2, 3]).should be_a Ratistics::Aggregates
  end

  specify '#frequencies creates a new Frequencies object' do
    Ratistics.frequencies([1, 2, 3]).should be_a Ratistics::Frequencies
  end

  specify '#percentiles creates a new Percentiles object' do
    Ratistics.percentiles([1, 2, 3]).should be_a Ratistics::Percentiles
  end
end
