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

      context '#midrange' do

        it 'returns the correct midrange for a multi-element sample' do
          sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
          mean = sample.midrange
          mean.should be_within(0.01).of(17.0)
        end

        it 'calculates the midrange using a block' do
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

          mean = sample.midrange{|item| item[:count]}
          mean.should be_within(0.01).of(17.0)
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

        it 'returns an array with all correct modes for a multi-modal sample' do
          sample = [1, 1, 1, 3, 3, 3, 4, 4, 4, 6, 6, 6, 9].freeze
          mode = sample.mode
          mode.count.should eq 4
          mode.should include(1)
          mode.should include(3)
          mode.should include(4)
          mode.should include(6)
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

      context '#standard_deviation' do

        it 'calculates standard deviation around the mean for a sample' do
          sample = [67, 72, 85, 93, 98].freeze
          standard_deviation = sample.standard_deviation
          standard_deviation.should be_within(0.01).of(11.882)
        end

        it 'calculates standard deviation around a datum for a sample' do
          sample = [67, 72, 85, 93, 98].freeze
          standard_deviation = sample.standard_deviation(85)
          standard_deviation.should be_within(0.01).of(12.049)
        end

        it 'calculates standard deviation around the mean for a sample with block' do
          sample = [
            {:count => 67},
            {:count => 72},
            {:count => 85},
            {:count => 93},
            {:count => 98},
          ].freeze

          standard_deviation = sample.standard_deviation{|item| item[:count]}
          standard_deviation.should be_within(0.01).of(11.882)
        end

        it 'calculates standard deviation around a datum for a sample with block' do
          sample = [
            {:count => 67},
            {:count => 72},
            {:count => 85},
            {:count => 93},
            {:count => 98},
          ].freeze

          standard_deviation = sample.standard_deviation(85){|item| item[:count]}
          standard_deviation.should be_within(0.01).of(12.049)
        end
      end

      context '#variance' do

        it 'calculates variance around the mean for a sample' do
          sample = [67, 72, 85, 93, 98].freeze
          variance = sample.variance
          variance.should be_within(0.01).of(141.2)
        end

        it 'calculates variance around a datum for a sample' do
          sample = [67, 72, 85, 93, 98].freeze
          variance = sample.variance(85)
          variance.should be_within(0.01).of(145.2)
        end

        it 'calculates variance around the mean for a sample with block' do
          sample = [
            {:count => 67},
            {:count => 72},
            {:count => 85},
            {:count => 93},
            {:count => 98},
          ].freeze

          variance = sample.variance{|item| item[:count]}
          variance.should be_within(0.01).of(141.2)
        end

        it 'calculates variance around a datum for a sample with block' do
          sample = [
            {:count => 67},
            {:count => 72},
            {:count => 85},
            {:count => 93},
            {:count => 98},
          ].freeze

          variance = sample.variance(85){|item| item[:count]}
          variance.should be_within(0.01).of(145.2)
        end
      end

      context '#range' do

        it 'returns the range for a sorted list' do
          sample = [13, 13, 13, 13, 14, 14, 16, 18, 21].freeze
          range = sample.range
          range.should be_within(0.01).of(8.0)
        end

        it 'returns the range for an unsorted list' do
          sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
          range = sample.range
          range.should be_within(0.01).of(8.0)
        end

        it 'calculates the range when using a block' do
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

          range = sample.range{|item| item[:count] }
          range.should be_within(0.01).of(8.0)
        end
      end

      context '#frequency' do

        it 'returns a multi-element hash for a multi-element sample' do
          sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

          frequency = sample.frequency

          frequency.count.should eq 5
          frequency[13].should eq 4
          frequency[14].should eq 2
          frequency[16].should eq 1
          frequency[18].should eq 1
          frequency[21].should eq 1
        end

        it 'returns a multi-element hash for a multi-element sample with a block' do
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

          frequency = sample.frequency{|item| item[:count]}

          frequency.count.should eq 5
          frequency[13].should eq 4
          frequency[14].should eq 2
          frequency[16].should eq 1
          frequency[18].should eq 1
          frequency[21].should eq 1
        end
      end

      context '#probability' do

        it 'returns a multi-element hash for a multi-element sample' do
          sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

          probability = sample.probability

          probability.count.should eq 5
          probability[13].should be_within(0.01).of(0.444)
          probability[14].should be_within(0.01).of(0.222) 
          probability[16].should be_within(0.01).of(0.111) 
          probability[18].should be_within(0.01).of(0.111) 
          probability[21].should be_within(0.01).of(0.111) 
        end

        it 'returns a multi-element hash for a multi-element sample with a block' do
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

          probability = sample.probability{|item| item[:count]}

          probability.count.should eq 5
          probability[13].should be_within(0.01).of(0.444)
          probability[14].should be_within(0.01).of(0.222) 
          probability[16].should be_within(0.01).of(0.111) 
          probability[18].should be_within(0.01).of(0.111) 
          probability[21].should be_within(0.01).of(0.111) 
        end
      end

      context '#probability_mean' do

        it 'calculates the mean for a multi-element sample' do
          sample = [1, 2, 3, 4, 5, 6, 6, 6, 6, 6].freeze
          mean = sample.probability_mean
          mean.should be_within(0.01).of(4.5)
        end

        it 'calculates the mean for a sample with a block' do
          sample = [
            {:count => 1},
            {:count => 2},
            {:count => 3},
            {:count => 4},
            {:count => 5},
            {:count => 6},
            {:count => 6},
            {:count => 6},
            {:count => 6},
            {:count => 6},
          ].freeze

          mean = sample.probability_mean{|item| item[:count]}
          mean.should be_within(0.01).of(4.5)
        end
      end

      context '#probability_variance' do

        it 'calculates the variance for a multi-element sample' do
          sample = [1, 2, 3, 4, 5, 6, 6, 6, 6, 6].freeze
          variance = sample.probability_variance
          variance.should be_within(0.01).of(3.25)
        end

        it 'calculates the variance for a sample with a block' do
          sample = [
            {:count => 1},
            {:count => 2},
            {:count => 3},
            {:count => 4},
            {:count => 5},
            {:count => 6},
            {:count => 6},
            {:count => 6},
            {:count => 6},
            {:count => 6},
          ].freeze

          variance = sample.probability_variance{|item| item[:count]}
          variance.should be_within(0.01).of(3.25)
        end
      end

      context '#percentiles' do

        it 'returns the percentiles in a multi-element sample' do
          sample = [22, 40].freeze

          centiles = sample.percentiles
          centiles.size.should eq 2

          centiles[0][0].should eq 22
          centiles[0][1].should be_within(0.001).of(25.0)

          centiles[1][0].should eq 40
          centiles[1][1].should be_within(0.001).of(75.0)
        end

        it 'returns the percentiles with a block' do
          sample = [
            {:count => 22},
            {:count => 40}
          ].freeze

          centiles = sample.percentiles{|item| item[:count]}
          centiles.size.should eq 2

          centiles[0][0].should eq 22
          centiles[0][1].should be_within(0.001).of(25.0)

          centiles[1][0].should eq 40
          centiles[1][1].should be_within(0.001).of(75.0)
        end
      end

      context '#nearest_rank' do

        it 'returns the nearest rank for a sample less that 100' do
          sample = [40, 15, 35, 20, 40, 50].freeze
          rank = sample.nearest_rank(35)
          rank.should eq 35
        end

        it 'returns the nearest rank with block' do
          sample = [
            {:count => 15},
            {:count => 20},
            {:count => 35},
            {:count => 40},
            {:count => 50}
          ].freeze
          rank = sample.nearest_rank(35){|item| item[:count]}
          rank.should eq 20
        end
      end

    end
  end
end
