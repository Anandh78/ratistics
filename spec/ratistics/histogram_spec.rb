require 'spec_helper'

module Ratistics
  describe Histogram do

    context '#frequency' do

      it 'returns nil for a nil sample' do
        Histogram.frequency(nil).should be_nil 
      end

      it 'returns nil for an empty sample' do
        Histogram.frequency([].freeze).should be_nil 
      end

      it 'returns a one-element hash for a one-item sample' do
        sample = [10].freeze
        frequency = Histogram.frequency(sample)
        frequency.should == {10 => 1}
      end

      it 'returns a multi-element hash for a multi-element sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        frequency = Histogram.frequency(sample)

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

        frequency = Histogram.frequency(sample){|item| item[:count]}
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

        frequency = Histogram.frequency(sample){|item| item[:count]}

        frequency.count.should eq 5
        frequency[13].should eq 4
        frequency[14].should eq 2
        frequency[16].should eq 1
        frequency[18].should eq 1
        frequency[21].should eq 1
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(13, 18, 14, 16, 21).freeze }

        specify do
          frequency = Histogram.frequency(list)

          frequency.count.should eq 5
          frequency[13].should eq 4
          frequency[14].should eq 2
          frequency[16].should eq 1
          frequency[18].should eq 1
          frequency[21].should eq 1
        end

        specify do
          frequency = Histogram.frequency(vector)

          frequency.count.should eq 5
          frequency[13].should eq 4
          frequency[14].should eq 2
          frequency[16].should eq 1
          frequency[18].should eq 1
          frequency[21].should eq 1
        end

        specify do
          frequency = Histogram.frequency(set)

          frequency.count.should eq 5
          frequency[13].should eq 1
          frequency[14].should eq 1
          frequency[16].should eq 1
          frequency[18].should eq 1
          frequency[21].should eq 1
        end
      end
    end

    context '#probability' do

      it 'returns nil for a nil sample' do
        Histogram.probability(nil).should be_nil 
      end

      it 'returns nil for an empty sample' do
        Histogram.probability([].freeze).should be_nil 
      end

      it 'returns a one-element hash for a one-item sample' do
        sample = [10].freeze
        probability = Histogram.probability(sample)
        probability.should == {10 => 1}
      end

      it 'returns a multi-element hash for a multi-element sample' do
        sample = [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze

        probability = Histogram.probability(sample)

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222) 
        probability[16].should be_within(0.01).of(0.111) 
        probability[18].should be_within(0.01).of(0.111) 
        probability[21].should be_within(0.01).of(0.111) 
      end

      it 'returns a one-element hash for a one-item sample with a block' do
        sample = [
          {:count => 10},
        ].freeze

        probability = Histogram.probability(sample){|item| item[:count]}
        probability.should == {10 => 1}
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

        probability = Histogram.probability(sample){|item| item[:count]}

        probability.count.should eq 5
        probability[13].should be_within(0.01).of(0.444)
        probability[14].should be_within(0.01).of(0.222) 
        probability[16].should be_within(0.01).of(0.111) 
        probability[18].should be_within(0.01).of(0.111) 
        probability[21].should be_within(0.01).of(0.111) 
      end

      context 'with Hamster' do

        let(:list) { Hamster.list(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:vector) { Hamster.vector(13, 18, 13, 14, 13, 16, 14, 21, 13).freeze }
        let(:set) { Hamster.set(13, 18, 14, 16, 21).freeze }

        specify do
          probability = Histogram.probability(list)

          probability.count.should eq 5
          probability[13].should be_within(0.01).of(0.444)
          probability[14].should be_within(0.01).of(0.222) 
          probability[16].should be_within(0.01).of(0.111) 
          probability[18].should be_within(0.01).of(0.111) 
          probability[21].should be_within(0.01).of(0.111) 
        end

        specify do
          probability = Histogram.probability(vector)

          probability.count.should eq 5
          probability[13].should be_within(0.01).of(0.444)
          probability[14].should be_within(0.01).of(0.222) 
          probability[16].should be_within(0.01).of(0.111) 
          probability[18].should be_within(0.01).of(0.111) 
          probability[21].should be_within(0.01).of(0.111) 
        end

        specify do
          probability = Histogram.probability(set)

          probability.count.should eq 5
          probability[13].should be_within(0.01).of(0.2)
          probability[14].should be_within(0.01).of(0.2) 
          probability[16].should be_within(0.01).of(0.2) 
          probability[18].should be_within(0.01).of(0.2) 
          probability[21].should be_within(0.01).of(0.2) 
        end

      end
    end
  end
end
