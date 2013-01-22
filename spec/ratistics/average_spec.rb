require 'spec_helper'

module Ratistics
  describe Average do

    context '#mean' do

      it 'returns zero for an empty list' do
        data = []
        Average.mean(data).should eq 0
      end

      it 'calculates the mean of an list' do
        data = [13, 18, 13, 14, 13, 16, 14, 21, 13]
        mean = Average.mean(data)
        mean.should be_within(0.01).of(15.0)
      end

      it 'calculates the mean using a block' do
        data = [
          {:count => 13},
          {:count => 18},
          {:count => 13},
          {:count => 14},
          {:count => 13},
          {:count => 16},
          {:count => 14},
          {:count => 21},
          {:count => 13},
        ]

        mean = Average.mean(data) {|item| item[:count] }
        mean.should be_within(0.01).of(15.0)
      end

      context 'with test data' do

        before(:all) do
          @pregnancies = Survey.get_pregnancy_data
        end

        it 'calculates the mean pregnancy length' do
          data = @pregnancies.filter{|item| item[:birthord] > 0}
          mean = Ratistics::Average.mean(data) {|birth| birth[:prglength]}
          mean.should be_within(0.01).of(38.56055968517709)
        end

        it 'calculates the mean pregnancy length for first babies' do
          data = @pregnancies.filter{|item| item[:birthord] == 1}
          mean = Ratistics::Average.mean(data) {|birth| birth[:prglength]}
          mean.should be_within(0.01).of(38.60095173351461)
        end

        it 'calculates the mean pregnancy length for not first babies' do
          data = @pregnancies.filter{|item| item[:birthord] > 1}
          mean = Ratistics::Average.mean(data) {|birth| birth[:prglength]}
          mean.should be_within(0.01).of(38.52291446673706)
        end
      end
    end

    context '#median' do

      it 'returns zero for an empty list' do
        data = []
        Average.median(data).should eq 0
      end

      it 'calculates the median of an even-number list' do
        data = [13, 18, 13, 14, 13, 16, 14, 21, 13, 0]
        median = Average.median(data)
        median.should be_within(0.01).of(13.5)
      end

      it 'calculates the median of an odd-number list' do
        data = [13, 18, 13, 14, 13, 16, 14, 21, 13]
        median = Average.median(data)
        median.should be_within(0.01).of(14.0)
      end

      it 'does not re-sort a sorted list' do
        data = [13, 13, 13, 13, 14, 14, 16, 18, 21]
        data.should_not_receive(:sort)
        data.should_not_receive(:sort_by)
        Average.median(data, true)
      end

      it 'calculates the median for an unsorted list' do
        data = [13, 18, 13, 14, 13, 16, 14, 21, 13]
        median = Average.median(data, false)
        median.should be_within(0.01).of(14.0)
      end

      it 'calculates the median of a sorted odd-number list using a block' do
        data = [
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

        median = Average.median(data) {|item| item[:count] }
        median.should be_within(0.01).of(14.0)
      end

      it 'calculates the median of a sorted even-number list using a block' do
        data = [
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
        ]

        median = Average.median(data) {|item| item[:count] }
        median.should be_within(0.01).of(13.5)
      end

      it 'does not attempt to sort when a using a block' do
        data = [
          {:count => 2},
        ]

        data.should_not_receive(:sort)
        data.should_not_receive(:sort_by)

        Average.median(data, false) {|item| item[:count] }
      end
    end

    context '#mode' do

      it 'returns an empty array for an empty list' do
        data = []
        mode = Average.mode(data)
        mode.should eq []
      end

      it 'returns the element for a one-element list' do
        data = [1]
        mode = Average.mode(data)
        mode.should eq [1]
      end

      it 'returns an array of one element for single-modal list' do
        data = [3, 7, 5, 13, 20, 23, 39, 23, 40, 23, 14, 12, 56, 23, 29]
        mode = Average.mode(data)
        mode.should eq [23]
      end

      it 'returns an array of two elements for a bimodal list' do
        data = [1, 3, 3, 3, 4, 4, 6, 6, 6, 9]
        mode = Average.mode(data)
        mode.count.should eq 2
        mode.should include(3)
        mode.should include(6)
      end

      it 'returns an array with all correct modes for a multi-modal list' do
        data = [1, 1, 1, 3, 3, 3, 4, 4, 4, 6, 6, 6, 9]
        mode = Average.mode(data)
        mode.count.should eq 4
        mode.should include(1)
        mode.should include(3)
        mode.should include(4)
        mode.should include(6)
      end

      it 'returns an array with every value when all elements are unique' do
        data = [1, 2, 3, 4, 5]
        mode = Average.mode(data)
        mode.count.should eq 5
        mode.should include(1)
        mode.should include(2)
        mode.should include(3)
        mode.should include(4)
        mode.should include(5)
      end

      it 'returns the correct values for a single-element list with a block' do
        data = [
          {:count => 1},
        ]

        mode = Average.mode(data) {|item| item[:count] }
        mode.should eq [1]
      end

      it 'returns the correct values for a single-modal list with a block' do
        data = [
          {:count => 1},
          {:count => 3},
          {:count => 2},
          {:count => 2},
          {:count => 2},
        ]

        mode = Average.mode(data) {|item| item[:count] }
        mode.should eq [2]
      end

      it 'returns the correct values for a bimodal list with a block' do
        data = [
          {:count => 1},
          {:count => 2},
          {:count => 3},
          {:count => 2},
          {:count => 1},
        ]

        mode = Average.mode(data) {|item| item[:count] }
        mode.count.should eq 2
        mode.should include(1)
        mode.should include(2)
      end

      it 'returns the correct values for a multimodal list with a block' do
        data = [
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
        ]

        mode = Average.mode(data) {|item| item[:count] }
        mode.count.should eq 4
        mode.should include(1)
        mode.should include(2)
        mode.should include(3)
        mode.should include(4)
      end

    end

    context '#range' do

      it 'returns zero for an empty list' do
        data = []
        Average.range(data).should eq 0
      end

      it 'returns zero for a one-element list' do
        data = [1]
        Average.range(data).should eq 0
      end

      it 'returns the range for a sorted list' do
        data = [13, 13, 13, 13, 14, 14, 16, 18, 21]
        range = Average.range(data, true)
        range.should be_within(0.01).of(8.0)
      end

      it 'returns the range for an unsorted list' do
        data = [13, 18, 13, 14, 13, 16, 14, 21, 13]
        range = Average.range(data, false)
        range.should be_within(0.01).of(8.0)
      end

      it 'does not re-sort a sorted list' do
        data = [13, 13, 13, 13, 14, 14, 16, 18, 21]
        data.should_not_receive(:sort)
        data.should_not_receive(:sort_by)
        Average.range(data, true)
      end

      it 'calculates the range when using a block' do
        data = [
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

        range = Average.range(data) {|item| item[:count] }
        range.should be_within(0.01).of(8.0)
      end

      it 'does not attempt to sort when a using a block' do
        data = [
          {:count => 2},
        ]

        data.should_not_receive(:sort)
        data.should_not_receive(:sort_by)

        Average.range(data, false) {|item| item[:count] }
      end
    end
  end
end
