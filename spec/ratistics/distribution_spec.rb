require 'spec_helper'

module Ratistics
  describe Distribution do

    context '#standard_deviation' do

      it 'returns zero when sample is nil' do
        Distribution.standard_deviation(nil).should eq 0
      end

      it 'returns zero when sample is empty' do
        Distribution.standard_deviation([]).should eq 0
      end

      it 'calculates standard deviation around the mean for a sample' do
        sample = [67, 72, 85, 93, 98]
        standard_deviation = Distribution.standard_deviation(sample)
        standard_deviation.should be_within(0.01).of(11.882)
      end

      it 'calculates standard deviation around a datum for a sample' do
        sample = [67, 72, 85, 93, 98]
        standard_deviation = Distribution.standard_deviation(sample, 85)
        standard_deviation.should be_within(0.01).of(12.049)
      end

      it 'calculates standard deviation around the mean for a sample with block' do
        sample = [
          {:count => 67},
          {:count => 72},
          {:count => 85},
          {:count => 93},
          {:count => 98},
        ]

        standard_deviation = Distribution.standard_deviation(sample){|item| item[:count]}
        standard_deviation.should be_within(0.01).of(11.882)
      end

      it 'calculates standard deviation around a datum for a sample with block' do
        sample = [
          {:count => 67},
          {:count => 72},
          {:count => 85},
          {:count => 93},
          {:count => 98},
        ]

        standard_deviation = Distribution.standard_deviation(sample, 85){|item| item[:count]}
        standard_deviation.should be_within(0.01).of(12.049)
      end
    end

    context '#variance' do

      it 'returns zero when sample is nil' do
        Distribution.variance(nil).should eq 0
      end

      it 'returns zero when sample is empty' do
        Distribution.variance([]).should eq 0
      end

      it 'calculates variance around the mean for a sample' do
        sample = [67, 72, 85, 93, 98]
        variance = Distribution.variance(sample)
        variance.should be_within(0.01).of(141.2)
      end

      it 'calculates variance around a datum for a sample' do
        sample = [67, 72, 85, 93, 98]
        variance = Distribution.variance(sample, 85)
        variance.should be_within(0.01).of(145.2)
      end

      it 'calculates variance around the mean for a sample with block' do
        sample = [
          {:count => 67},
          {:count => 72},
          {:count => 85},
          {:count => 93},
          {:count => 98},
        ]

        variance = Distribution.variance(sample){|item| item[:count]}
        variance.should be_within(0.01).of(141.2)
      end

      it 'calculates variance around a datum for a sample with block' do
        sample = [
          {:count => 67},
          {:count => 72},
          {:count => 85},
          {:count => 93},
          {:count => 98},
        ]

        variance = Distribution.variance(sample, 85){|item| item[:count]}
        variance.should be_within(0.01).of(145.2)
      end
    end

    context '#range' do

      it 'returns zero when sample is nil' do
        Distribution.range(nil).should eq 0
      end

      it 'returns zero for an empty list' do
        sample = []
        Distribution.range(sample).should eq 0
      end

      it 'returns zero for a one-element list' do
        sample = [1]
        Distribution.range(sample).should eq 0
      end

      it 'returns the range for a sorted list' do
        sample = [13, 13, 13, 13, 14, 14, 16, 18, 21]
        range = Distribution.range(sample, true)
        range.should be_within(0.01).of(8.0)
      end

      it 'returns the range for an unsorted list' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13]
        range = Distribution.range(sample, false)
        range.should be_within(0.01).of(8.0)
      end

      it 'does not re-sort a sorted list' do
        sample = [13, 13, 13, 13, 14, 14, 16, 18, 21]
        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)
        Distribution.range(sample, true)
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
        ]

        range = Distribution.range(sample) {|item| item[:count] }
        range.should be_within(0.01).of(8.0)
      end

      it 'does not attempt to sort when a using a block' do
        sample = [
          {:count => 2},
        ]

        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)

        Distribution.range(sample, false) {|item| item[:count] }
      end
    end
  end
end
