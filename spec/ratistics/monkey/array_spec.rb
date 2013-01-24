require 'spec_helper'
require 'ratistics/monkey'

module Ratistics
  module Monkey

  describe ::Array do

    context '#mean' do

      it 'calculates the mean of a sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
        mean = sample.mean
        mean.should be_within(0.01).of(15.0)
      end

      it 'calculates the mean using a block' do
        sample = [
          {:count => 13},
          {:count => 18},
          {:count => 13},
          {:count => 14},
          {:count => 13},
          {:count => 16},
          {:count => 14},
          {:count => 21},
          {:count => 13},
        ].freeze

        mean = sample.mean{|item| item[:count] }
        mean.should be_within(0.01).of(15.0)
      end
    end

    context '#truncated_mean' do

      it 'calculates the truncated mean' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13, 11, 19, 19, 17, 16, 13, 12, 12, 12, 20, 11].freeze
        mean = sample.truncated_mean(10)
        mean.should be_within(0.01).of(14.625)
      end

      it 'calculates the truncated mean with a block' do
        sample = [
          {:count => 11},
          {:count => 11}, 
          {:count => 12},
          {:count => 12},
          {:count => 12},
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 14},
          {:count => 14},
          {:count => 16},
          {:count => 16},
          {:count => 17},
          {:count => 18},
          {:count => 19},
          {:count => 19},
          {:count => 20},
          {:count => 21},
        ].freeze

        mean = sample.truncated_mean(10){|item| item[:count]}
        mean.should be_within(0.01).of(14.625)
      end
    end

    context '#median' do

      it 'calculates the median of an even-number sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13, 0].freeze
        median = sample.median
        median.should be_within(0.01).of(13.5)
      end

      it 'calculates the median of an odd-number sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
        median = sample.median
        median.should be_within(0.01).of(14.0)
      end

      it 'calculates the median using a block' do
        sample = [
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 13},
          {:count => 14},
          {:count => 14},
          {:count => 16},
          {:count => 18},
          {:count => 21},
        ].freeze

        median = sample.median{|item| item[:count] }
        median.should be_within(0.01).of(14.0)
      end
    end

    context '#mode' do

      it 'returns an array of one element for single-modal sample' do
        sample = [3, 7, 5, 13, 20, 23, 39, 23, 40, 23, 14, 12, 56, 23, 29].freeze
        mode = sample.mode
        mode.should eq [23]
      end

      it 'returns an array with all correct modes for a multi-modal sample' do
        sample = [1, 1, 1, 3, 3, 3, 4, 4, 4, 6, 6, 6, 9].freeze
        mode = sample.mode
        mode.count.should eq 4
        mode.should include(1)
        mode.should include(3)
        mode.should include(4)
        mode.should include(6)
      end

      it 'returns the correct values for a single-modal sample with a block' do
        sample = [
          {:count => 1},
          {:count => 3},
          {:count => 2},
          {:count => 2},
          {:count => 2},
        ].freeze

        mode = sample.mode{|item| item[:count] }
        mode.should eq [2]
      end

      it 'returns the correct values for a multimodal sample with a block' do
        sample = [
          {:count => 0},
          {:count => 1},
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 1},
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 5},
        ].freeze

        mode = sample.mode{|item| item[:count] }
        mode.count.should eq 4
        mode.should include(1)
        mode.should include(2)
        mode.should include(3)
        mode.should include(4)
      end

    end
  end
end
end
