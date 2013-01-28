require 'spec_helper'

module Ratistics
  describe Average do

    context '#mean' do

      it 'returns zero for a nil sample' do
        Average.mean(nil).should eq 0
      end

      it 'returns zero for an empty sample' do
        Average.mean([].freeze).should eq 0
      end

      it 'calculates the mean of a sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
        mean = Average.mean(sample)
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

        mean = Average.mean(sample) {|item| item[:count] }
        mean.should be_within(0.01).of(15.0)
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(13, 18, 14, 16, 21).freeze }

        specify { Average.mean(list).should be_within(0.01).of(15.0) }

        specify { Average.mean(vector).should be_within(0.01).of(15.0) }

        specify { Average.mean(set).should be_within(0.01).of(16.4) }
      end
    end

    context '#truncated_mean' do

      it 'returns zero for a nil sample' do
        Average.truncated_mean(nil, 10).should eq 0
      end

      it 'returns zero for an empty sample' do
        Average.truncated_mean([].freeze, 10).should eq 0
      end

      it 'raises an exception for truncation equal to or greater than 50%' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13, 11, 19, 19, 17, 16, 13, 12, 12, 12, 20, 11].freeze
        lambda {
          Average.truncated_mean(sample, 50)
        }.should raise_error ArgumentError
      end

      it 'calculates the statistical mean for truncation equal to 0%' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13, 11, 19, 19, 17, 16, 13, 12, 12, 12, 20, 11].freeze
        mean = Average.truncated_mean(sample, 0)
        mean.should be_within(0.01).of(14.85)
      end

      it 'calculates the truncated mean when the truncation can be exact' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13, 11, 19, 19, 17, 16, 13, 12, 12, 12, 20, 11].freeze
        mean = Average.truncated_mean(sample, 10)
        mean.should be_within(0.01).of(14.625)
      end

      it 'it rounds truncation to one decimal place' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13, 11, 19, 19, 17, 16, 13, 12, 12, 12, 20, 11].freeze
        mean = Average.truncated_mean(sample, 10.04)
        mean.should be_within(0.01).of(14.625)
      end

      it 'it accepts truncation as a decimal' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13, 11, 19, 19, 17, 16, 13, 12, 12, 12, 20, 11].freeze
        mean = Average.truncated_mean(sample, 0.10)
        mean.should be_within(0.01).of(14.625)
      end

      it 'calculates the interpolated mean when the truncation cannot be exact' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13, 11, 19, 19, 17, 16, 13, 12, 12, 12, 20, 11].freeze
        mean = Average.truncated_mean(sample, 12.5)
        mean.should be_within(0.01).of(14.5625)
      end

      it 'does not sort a sample that is already sorted' do
        sample = [11, 11, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 16, 16, 17, 18, 19, 19, 20, 21]
        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)
        mean = Average.truncated_mean(sample, 10, true)
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

        mean = Average.truncated_mean(sample, 10){|item| item[:count]}
        mean.should be_within(0.01).of(14.625)
      end

      it 'calculates the interpolated truncated mean with a block' do
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

        mean = Average.truncated_mean(sample, 12.5){|item| item[:count]}
        mean.should be_within(0.01).of(14.5625)
      end

      it 'does not sort a sample with a block' do
        sample = [
          {:count => 13},
        ]

        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)
        mean = Average.truncated_mean(sample, 10){|item| item[:count]}
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(11, 11, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 16, 16, 17, 18, 19, 19, 20, 21).freeze }
        let(:vector) { Hamster.vector(11, 11, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 16, 16, 17, 18, 19, 19, 20, 21).freeze }
        let(:set) { Hamster.set(11, 11, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 16, 16, 17, 18, 19, 19, 20, 21).freeze }

        specify { Average.truncated_mean(list, 10).should be_within(0.01).of(14.625) }

        # NOTE: Hamster::Vector does not have a slice method
        #specify { Average.truncated_mean(vector, 10, true).should be_within(0.01).of(14.625) }

        specify { Average.truncated_mean(set, 10).should be_within(0.01).of(16.125) }
      end
    end

    context '#midrange' do

      it 'returns zero for a nil sample' do
        Average.midrange(nil).should eq 0
      end

      it 'returns zero for an empty sample' do
        Average.midrange([].freeze).should eq 0
      end

      it 'returns the value for a one-element sample' do
        Average.midrange([10].freeze).should eq 10
      end

      it 'returns the mean for a two-element sample' do
        Average.midrange([5, 15].freeze).should eq 10
      end

      it 'returns the correct midrange for a multi-element sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
        mean = Average.midrange(sample)
        mean.should eq 17
      end

      it 'does not sort a sample that is already sorted' do
        sample = [13, 13, 13, 13, 14, 14, 16, 18, 21]
        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)
        mean = Average.midrange(sample, true)
      end

      it 'calculates the midrange using a block' do
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

        mean = Average.midrange(sample){|item| item[:count]}
        mean.should eq 17
      end

      it 'does not sort a sample with a block' do
        sample = [
          {:count => 13},
        ]

        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)
        mean = Average.midrange(sample){|item| item[:count]}
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(13, 13, 13, 13, 14, 14, 16, 18, 21).freeze }
        let(:vector) { Hamster.vector(13, 13, 13, 13, 14, 14, 16, 18, 21).freeze }
        let(:set) { Hamster.set(13, 13, 13, 13, 14, 14, 16, 18, 21).freeze }

        specify { Average.midrange(list).should eq 17 }

        specify { Average.midrange(vector, true).should eq 17 }

        specify { Average.midrange(set).should eq 17 }
      end
    end

    context '#median' do

      it 'returns zero for a nil sample' do
        Average.mean(nil).should eq 0
      end

      it 'returns zero for an empty sample' do
        Average.median([].freeze).should eq 0
      end

      it 'calculates the median of an even-number sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13, 0].freeze
        median = Average.median(sample)
        median.should be_within(0.01).of(13.5)
      end

      it 'calculates the median of an odd-number sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
        median = Average.median(sample)
        median.should be_within(0.01).of(14.0)
      end

      it 'does not re-sort a sorted sample' do
        sample = [13, 13, 13, 13, 14, 14, 16, 18, 21]
        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)
        Average.median(sample, true)
      end

      it 'calculates the median for an unsorted sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze
        median = Average.median(sample, false)
        median.should be_within(0.01).of(14.0)
      end

      it 'calculates the median of a sorted odd-number sample using a block' do
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

        median = Average.median(sample) {|item| item[:count] }
        median.should be_within(0.01).of(14.0)
      end

      it 'calculates the median of a sorted even-number sample using a block' do
        sample = [
          {:count => 0},
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

        median = Average.median(sample) {|item| item[:count] }
        median.should be_within(0.01).of(13.5)
      end

      it 'does not attempt to sort when a using a block' do
        sample = [
          {:count => 2},
        ]

        sample.should_not_receive(:sort)
        sample.should_not_receive(:sort_by)

        Average.median(sample, false) {|item| item[:count] }
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(13, 13, 13, 13, 14, 14, 16, 18, 21).freeze }
        let(:set) { Hamster.set(13, 18, 14, 16, 21).freeze }

        specify { Average.median(list).should be_within(0.01).of(14.0) }

        specify { Average.median(vector, true).should be_within(0.01).of(14.0) }

        specify { Average.median(set).should be_within(0.01).of(16.0) }

      end
    end

    context '#mode' do

      it 'returns an empty array for a nil sample' do
        Average.mode(nil).should eq []
      end

      it 'returns an empty array for an empty sample' do
        Average.mode([].freeze).should eq []
      end

      it 'returns the element for a one-element sample' do
        sample = [1].freeze
        mode = Average.mode(sample)
        mode.should eq [1]
      end

      it 'returns an array of one element for single-modal sample' do
        sample = [3, 7, 5, 13, 20, 23, 39, 23, 40, 23, 14, 12, 56, 23, 29].freeze
        mode = Average.mode(sample)
        mode.should eq [23]
      end

      it 'returns an array of two elements for a bimodal sample' do
        sample = [1, 3, 3, 3, 4, 4, 6, 6, 6, 9].freeze
        mode = Average.mode(sample)
        mode.count.should eq 2
        mode.should include(3)
        mode.should include(6)
      end

      it 'returns an array with all correct modes for a multi-modal sample' do
        sample = [1, 1, 1, 3, 3, 3, 4, 4, 4, 6, 6, 6, 9].freeze
        mode = Average.mode(sample)
        mode.count.should eq 4
        mode.should include(1)
        mode.should include(3)
        mode.should include(4)
        mode.should include(6)
      end

      it 'returns an array with every value when all elements are unique' do
        sample = [1, 2, 3, 4, 5].freeze
        mode = Average.mode(sample)
        mode.count.should eq 5
        mode.should include(1)
        mode.should include(2)
        mode.should include(3)
        mode.should include(4)
        mode.should include(5)
      end

      it 'returns the correct values for a single-element sample with a block' do
        sample = [
          {:count => 1},
        ].freeze

        mode = Average.mode(sample) {|item| item[:count] }
        mode.should eq [1]
      end

      it 'returns the correct values for a single-modal sample with a block' do
        sample = [
          {:count => 1},
          {:count => 3},
          {:count => 2},
          {:count => 2},
          {:count => 2},
        ].freeze

        mode = Average.mode(sample) {|item| item[:count] }
        mode.should eq [2]
      end

      it 'returns the correct values for a bimodal sample with a block' do
        sample = [
          {:count => 1},
          {:count => 2},
          {:count => 3},
          {:count => 2},
          {:count => 1},
        ].freeze

        mode = Average.mode(sample) {|item| item[:count] }
        mode.count.should eq 2
        mode.should include(1)
        mode.should include(2)
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

        mode = Average.mode(sample) {|item| item[:count] }
        mode.count.should eq 4
        mode.should include(1)
        mode.should include(2)
        mode.should include(3)
        mode.should include(4)
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(13, 18, 14, 16, 21).freeze }

        specify { Average.mode(list).should eq [13] }

        specify { Average.mode(vector).should eq [13] }

        specify do
          mode = Average.mode(set)
          mode.count.should eq 5
          mode.should include(16)
          mode.should include(18)
          mode.should include(13)
          mode.should include(14)
          mode.should include(21)
        end

      end

    end
  end
end
