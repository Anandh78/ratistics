require 'spec_helper'

module Ratistics
  describe Average do

    context '#mean' do

      it 'returns zero for an empty list' do
        data = []
        Average.mean(data).should eq 0
      end

      it 'calculates the mean of an list' do
        data = [2, 3, 4, 5, 6]
        mean = Average.mean(data)
        mean.should be_within(0.01).of(4.0)
      end

      it 'calculates the mean using a block' do
        data = [
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 5},
          {:count => 6},
        ]

        mean = Average.mean(data) {|item| item[:count] }
        mean.should be_within(0.01).of(4.0)
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
        data = [1, 2, 3, 4, 5, 6]
        median = Average.median(data)
        median.should be_within(0.01).of(3.5)
      end

      it 'calculates the median of an odd-number list' do
        data = [2, 3, 4, 5, 6]
        median = Average.median(data)
        median.should be_within(0.01).of(4.0)
      end

      it 'does not re-sort a sorted list' do
        data = [2, 3, 4, 5, 6]
        data.should_not_receive(:sort)
        data.should_not_receive(:sort_by)
        Average.median(data, true)
      end

      it 'calculates the median for an unsorted list' do
        data = [4, 2, 6, 3, 5]
        median = Average.median(data, false)
        median.should be_within(0.01).of(4.0)
      end

      it 'calculates the median of a sorted odd-number list using a block' do
        data = [
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 5},
          {:count => 6},
        ]

        median = Average.median(data) {|item| item[:count] }
        median.should be_within(0.01).of(4.0)
      end

      it 'calculates the median of a sorted even-number list using a block' do
        data = [
          {:count => 1},
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 5},
          {:count => 6},
        ]

        median = Average.median(data) {|item| item[:count] }
        median.should be_within(0.01).of(3.5)
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
