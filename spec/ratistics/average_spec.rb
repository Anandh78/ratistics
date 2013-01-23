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

      #context 'with test sample' do

        #before(:all) do
          #@pregnancies = Survey.get_pregnancy_data
        #end

        #it 'calculates the mean pregnancy length' do
          #sample = @pregnancies.filter{|item| item[:birthord] > 0}.freeze
          #mean = Ratistics::Average.mean(sample) {|birth| birth[:prglength]}
          #mean.should be_within(0.01).of(38.56055968517709)
        #end

        #it 'calculates the mean pregnancy length for first babies' do
          #sample = @pregnancies.filter{|item| item[:birthord] == 1}.freeze
          #mean = Ratistics::Average.mean(sample) {|birth| birth[:prglength]}
          #mean.should be_within(0.01).of(38.60095173351461)
        #end

        #it 'calculates the mean pregnancy length for not first babies' do
          #sample = @pregnancies.filter{|item| item[:birthord] > 1}.freeze
          #mean = Ratistics::Average.mean(sample) {|birth| birth[:prglength]}
          #mean.should be_within(0.01).of(38.52291446673706)
        #end
      #end
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
