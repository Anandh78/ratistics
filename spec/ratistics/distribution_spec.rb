require 'spec_helper'

module Ratistics
  describe Distribution do

    context '#standard_deviation' do

      it 'returns zero when sample is nil' do
        Distribution.standard_deviation(nil).should eq 0
      end

      it 'returns zero when sample is empty' do
        Distribution.standard_deviation([].freeze).should eq 0
      end

      it 'calculates standard deviation around the mean for a sample' do
        sample = [67, 72, 85, 93, 98].freeze
        standard_deviation = Distribution.standard_deviation(sample)
        standard_deviation.should be_within(0.01).of(11.882)
      end

      it 'calculates standard deviation around a datum for a sample' do
        sample = [67, 72, 85, 93, 98].freeze
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
        ].freeze

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
        ].freeze

        standard_deviation = Distribution.standard_deviation(sample, 85){|item| item[:count]}
        standard_deviation.should be_within(0.01).of(12.049)
      end
    end

    context '#variance' do

      it 'returns zero when sample is nil' do
        Distribution.variance(nil).should eq 0
      end

      it 'returns zero when sample is empty' do
        Distribution.variance([].freeze).should eq 0
      end

      it 'calculates variance around the mean for a sample' do
        sample = [67, 72, 85, 93, 98].freeze
        variance = Distribution.variance(sample)
        variance.should be_within(0.01).of(141.2)
      end

      it 'calculates variance around a datum for a sample' do
        sample = [67, 72, 85, 93, 98].freeze
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
        ].freeze

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
        ].freeze

        variance = Distribution.variance(sample, 85){|item| item[:count]}
        variance.should be_within(0.01).of(145.2)
      end
    end

    context '#range' do

      it 'returns zero when sample is nil' do
        Distribution.range(nil).should eq 0
      end

      it 'returns zero for an empty list' do
        Distribution.range([].freeze).should eq 0
      end

      it 'returns zero for a one-element list' do
        sample = [1].freeze
        Distribution.range(sample).should eq 0
      end

      it 'returns the range for a sorted list' do
        sample = [13, 13, 13, 13, 14, 14, 16, 18, 21].freeze
        range = Distribution.range(sample, true)
        range.should be_within(0.01).of(8.0)
      end

      it 'returns the range for an unsorted list' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
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
        ].freeze

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

    context '#frequency' do

      it 'returns nil for a nil sample' do
        Distribution.frequency(nil).should be_nil 
      end

      it 'returns nil for an empty sample' do
        Distribution.frequency([].freeze).should be_nil 
      end

      it 'returns a one-element hash for a one-item sample' do
        sample = [10].freeze
        frequency = Distribution.frequency(sample)
        frequency.should == {10 => 1}
      end

      it 'returns a multi-element hash for a multi-element sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        frequency = Distribution.frequency(sample)

        frequency.count.should eq 5
        frequency[13].should eq 4
        frequency[14].should eq 2
        frequency[16].should eq 1
        frequency[18].should eq 1
        frequency[21].should eq 1
      end

      it 'returns a one-element hash for a one-item sample with a block' do
        sample = [
          {:count => 10},
        ].freeze

        frequency = Distribution.frequency(sample){|item| item[:count]}
        frequency.should == {10 => 1}
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

        frequency = Distribution.frequency(sample){|item| item[:count]}

        frequency.count.should eq 5
        frequency[13].should eq 4
        frequency[14].should eq 2
        frequency[16].should eq 1
        frequency[18].should eq 1
        frequency[21].should eq 1
      end

    end
  end
end
