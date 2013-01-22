require 'spec_helper'

module Ratistics
  describe Average do

    context '#mean' do

      it 'returns zero for an empty array' do
        data = []
        Average.mean(data).should eq 0
      end

      it 'calculates the mean of an array' do
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

      it 'returns zero for an empty array' do
        data = []
        Average.median(data).should eq 0
      end

      it 'calculates the median of an even-number array' do
        data = [1, 2, 3, 4, 5, 6]
        mean = Average.median(data)
        mean.should be_within(0.01).of(3.5)
      end

      it 'calculates the median of an odd-number array' do
        data = [2, 3, 4, 5, 6]
        mean = Average.median(data)
        mean.should be_within(0.01).of(4.0)
      end

      it 'does not re-sort a sorted array' do
        data = [2, 3, 4, 5, 6]
        data.should_not_receive(:sort)
        data.should_not_receive(:sort_by)
        Average.median(data, true)
      end

      it 'calculates the median for an unsorted array' do
        data = [4, 2, 6, 3, 5]
        mean = Average.median(data, false)
        mean.should be_within(0.01).of(4.0)
      end

      it 'calculates the median of a sorted odd-number array using a block' do
        data = [
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 5},
          {:count => 6},
        ]

        mean = Average.median(data) {|item| item[:count] }
        mean.should be_within(0.01).of(4.0)
      end

      it 'calculates the median of a sorted even-number array using a block' do
        data = [
          {:count => 1},
          {:count => 2},
          {:count => 3},
          {:count => 4},
          {:count => 5},
          {:count => 6},
        ]

        mean = Average.median(data) {|item| item[:count] }
        mean.should be_within(0.01).of(3.5)
      end

      it 'does not attempt to sort when a block is given' do
        data = [
          {:count => 2},
        ]

        data.should_not_receive(:sort)
        data.should_not_receive(:sort_by)

        mean = Average.median(data, false) {|item| item[:count] }
      end
    end

  end
end
